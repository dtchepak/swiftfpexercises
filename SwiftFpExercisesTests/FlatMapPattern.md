
The Parser exercise goes through the process of defining a few key functions that combine Parser values,
then demonstrates how more complicated Parsers can be assembled using those functions, without having to
continually dig into the details of how the Parsers work. For example, we can use `charIs("a") ||| charIs("b")`
to produce a parser that will match a lowercase "a" or a lowercase "b", without having to know the details of
handling input and pattern matching on ParseResults and ParseErrors. These details are instead abstracted
away in the ||| operator.

Some combinators like map, flatMap and apply (<*>) are much more broadly applicable that just for Parsers.
It took me a lot of practice implementing and using these functions to feel comfortable with them, but
before that I used a pattern to gain an approximate intuition about them that seemed to get me through
most of the exercises. So here it is: Dave's guide to fumbling through with flatMap. :)


MAP
===

If we have a Parser<T>, and we want a Parser<S>, we can use map to change the `T` to an `S` (provided
we have a function `T -> S` handy). The intuition I use is that I want to change the value contained with
the Parser instance. 

WARNING: the "container" analogy is known to be a potential source of confusion, as map and flatMap can be 
used with non-containery types as well. Provided I kept in mind that thinking of these things as "containers"
is only an approximation, I've found I can use the approximation without it causing me any trouble (at least not yet).

For example, say we have something that can parse a record that contains the temperature in Celcius. If
we want to take that value and convert it to Fahrenheit, we can use map:

    parseCelcius.map({ celcius in c_to_f(celcius) })

or just:

    parseCelcius.map(c_to_f)



FLATMAP
=======

So now say we want to use the values from multiple parsers. As an example let's imagine we have a Car
type that has a Make and a Model.

    parseMake.map( { make in parseModel.map( { model in Car(make: make, model: model) }) } )

Let's take this bit-by-bit. We'll start with the inner-most expression, and work outwards to find
the type of the entire expression:

    // Step 1:
    { model in Car(make: make, model: model) }) }
    // This is a function: Model -> Car


    // Step 2:
    parseModel.map( { model in Car(make: make, model: model) }) }
    // This is a value: Parser<Car>
    // It works by taking a Parser<Model>, and mapping the `Model -> Car` function.
    // This gives us a Parser<Car> (the `Model` is transformed to a `Car`).


    // Step 3:
    { make in parseModel.map( { model in Car(make: make, model: model) }) }
    // This is a function: Make -> Parser<Car>

    
    // Step 4:
    parseMake.map( { make in parseModel.map( { model in Car(make: make, model: model) }) } )
    // This is a value: Parser<Parser<Car>>
    // It works by taking a Parser<Make>, and mapping the `Make -> Parser<Car>` function.
    // This gives us a Parser<Parser<Car>>. The `Make` is transformed to a `Parser<Car>`.

This is where `flatMap` comes in to the picture. It does a `map`, but flattens the result out
to remove the nested Parser.

    So mapping is: Parser<A> -> (A ->        B ) -> Parser<B>
    FlatMap is:    Parser<A> -> (A -> Parser<B>) -> Parser<B>

Which means we can use the following to get a `Parser<Car>`, instead of a `Parser<Parser<Car>>`:

    parseMake.flatMap( { make in parseModel.map( { model in Car(make: make, model: model) }) } )



CHEAT'S GUIDE TO USING FLATMAP
==============================

When I first saw similar steps to those above, each individual step made sense to me, but trying to put it
all together kept frying my brain. In the meantime, I used a pattern for combining multiple Parsers.

I read this:

    parserA.flatMap( { a in ...

As:

    from `parserA`, take the value `a`, and then ...


I could then "get the values out" (WARNING: approximation) of several parsers and put them back together. Re-writing
the above Car Parser example:

    // NOTE: THIS CODE WILL NOT COMPILE:
    parseMake.flatMap(  { make in
    parseModel.flatMap( { model in
        Car(make: make, model: model)
    })})

Here I am getting the `make` and `model` out of their parsers, and assemblying a `Car` out of them. Unfortunately
this doesn't compile, because the function passed to `flatMap` has to return a parser (`A -> Parser<B>`). So I
have to wrap my Car back up again in a Parser. To do this we have the handy `valueParser` function, which takes
any value and creates a parser that will return it again. It is a function of type `A -> Parser<A>`.

    parseMake.flatMap(  { make in
    parseModel.flatMap( { model in
        valueParser( Car(make: make, model: model) )
    })})

So here is the pattern. When we need to "get the values out" (approximation again) of multiple parsers (or anything
that has flatMap and an equivalent to valueParser), we can chain them together like this:


    parserA.flatMap( { a in
    parserB.flatMap( { b in
    parserC.flatMap( { c in
    parserD.flatMap( { d in
    ...
        valueParser( combine(a, b, c, d, ... ) )
    ... })})})})


I find lining up the statements so that all the `{` are vertically aligned helps. 
It also makes it a bit easier if we define `>>-` as an operator for flatMap.
The operator lets us drop a few parentheses:


    parserA >>- { a in
    parserB >>- { b in
    parserC >>- { c in
    parserD >>- { d in
    ...
        valueParser( combine(a, b, c, d, ... ) )
    ... }}}}


Not sure if that helps you at all, but I found blindly following this pattern was enough to get me through the exercises.
After I repeated the exercises a few times, tried other ones, and also experimented with these ideas in my own code, I started
to gain more understanding and relied less on the pattern. (I still find the pattern useful though. :) )
