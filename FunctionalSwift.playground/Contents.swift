/*:
## *functional* *swift* - crash course
---
In functional programming functions are
first class citizens, which basically means we can
pass those functions as arguments to other functions.
We will go through 3 types of operations during the course: map, filter and reduce.
Don't forget to try your own code after the examples.
### 1. **map**
---
With this operation we are able to transform data.
This first example is not very useful, but I believe it explains the
very basic idea on how the map operation transform things.
The method receives an **Int**(value) and uses it as
an argument to the function you pass when calling it (transform).
*/
import UIKit

// this function receives an Int and a function
// transform will run your function and return an Int
func map(value: Int, transform: Int -> Int) -> Int {
    return transform(value)
}

map(10) { x in x * x }         // x = 10 , transform: 10 * 10 = 100
map(9)  { x in x * (x * 10) }  // x = 981, transform: 9  * (9 * 10) = 981
/*:
So basically what we did was to transform an **Int** into another **Int**
by passing the kind of transformation we want as a function. But in this case
we are dealing with Ints only, how about something more generic?

#### 1.1 Generics
**Generics** are powerful. There's a lot to say and read about it,
but we're going to get right to the point. How about creating awesome functions
that can work with any data type... that's it.
Let's apply this idea into our last example.
We are using the letter T to tell swift that this is a generic type, but you can use
others letters and words as well as long as they are not reserved or already in use.
*/
func map<T>(value: T, transform: T -> T) -> T {
    return transform(value)
}

map("This") { x in x + " is a text" } // This is a text

// or if you are an old school Objective-C coder
map("This") { x in x.stringByAppendingString(" is another text") } // This is another Text

// oh, and we can send other methods as an argument as well
func addOne(x: Int) -> Int {
    return x + 1
}

map(1) { x in addOne(x) } // 2
/*:
Ok, we started with simple examples on what means the map operation,
but it's when dealing with arrays and more complex structures that
we can see how this really come in handy.

Swift already have an array map operation "*yourArray.map()*", but we are going to
recreate part of it in order to understand the innerworks.
We are going to write it as an extension, which is as the name
say, extensions to our current type that can be accessed anywhere in your project.
Our extension will receive any type of array, loop
through each **Element**, transform it and finally
append it into our results array. The **Element** keyword
is a representation of an item inside the array,
so in the argument we are sending one **Element** and
getting back our value that can be of any type.
*/
extension Array {
    func map<ICanHandleAnyType>(transform: Element -> ICanHandleAnyType) -> [ICanHandleAnyType] {
        var result: [ICanHandleAnyType] = []
        
        for obj in self {
            result.append(transform(obj))
        }
        
        return result
    }
}

var values = [10, 11, 12, 20]
values.map { x in x * x } // 100, 121, 144, 400

// or using another method
func power2(x: Int) -> Int {
    return x * x
}

values.map { x in power2(x) } // 100, 121, 144, 400

// concatenating strings
let names = ["Walter", "Jesse", "Saul"]
names.map { x in "Call me " + x }
/*:
So, it doesn't matter the kind of array it is, what matters is the function you pass along,
it needs to be able to handle the type of data you are dealing inside the array.
And yes, you can use it with custom types, like in this tuple array:
*/
let breakingBadFavoriteChars = [("Walter", "White"), ("Jesse", "Pinkman"), ("Saul", "Goodman")]
breakingBadFavoriteChars.map { firstName, lastName in "The name is " + lastName + "... " + firstName + " " + lastName }
/*: 
resulting in:
* The name is White... Walter White
* The name is Pinkman... Jesse Pinkman
* The name is Goodman... Saul Goodman

### 2. filter
As the name says, with this operation we are able to filter data based on rules.
In the next example we re-implement (yes, there is a built-in filter operation already) part of the
filter operation in an array extension.
The basic idea here is to pass an array of any type and pass the rule we want to check for true or false,
as an argument.
*/
extension Array {
    func filter(check: Element -> Bool) -> [Element] {
        var result: [Element] = []
        
        for obj in self where check(obj) {
            result.append(obj)
        }
        
        return result
    }
}

func checkForEven(value: Int) -> Bool {
    if value % 2 == 0 {
        return true
    }
    
    return false
}

// no rocket science here, we're just going to declare an array of Ints
// and use the generic filter to check for even numbers
// the result will be in a new array called filteredValues.
values = [1, 2, 3, 4, 5, 6, 890]
var filteredValues = values.filter { x in checkForEven(x) }
filteredValues // 2, 4, 6, 890

filteredValues = values.filter { x in 4...6 ~= x}
filteredValues // 4, 5, 6
/*:
Wow, you just blew my mind, what the f@#$ means ~= ???

Don't worry! This is a special operator to check if a number is in between a range,
like in:
*/
// values[5] is equal to 6
if values[5] >= 1 && values[5] <= 10 {
    // ok the "values[6]" is between 1 and 10
    // and the condition is true
}

// the swift way:
if 1...10 ~= values[5] {
    // same thing
}
/*:
And that's what we did before, we checked each value inside the array to see which ones
were between 4 and 6.

Ok, so basically I can check for anything? 

Yes. Example: I have a list of filenames
from a folder inside my app, but I want to filter only for PNG images, what can I do?
You can filter by the checking the file suffix with the string method hasSuffix("png"), 
the result will be the array of the .png.

Can I use map and filter together? 

Yes, the next example will show you how to do that.
We will use the same values array, but this time the values will be mapped with the
addOne() method and the result of the mapping will be filtered for numbers divisible by 3.
*/
filteredValues = values.map { x in addOne(x) } .filter { x in x % 3 == 0 }
filteredValues // 3, 6, 891
/*:

### 3. reduce
With the reduce operation we are able to process a series of values
into a single result. Ex: sum all the values in an array, concatenate strings.
Let's begin with a reduce array extension, concatenating a few strings, already in swift... no suprises :)
*/
extension Array {
    func reduce<T>(initialValue: T, combine: (T, Element) -> T) -> T {
        var result = initialValue
        
        for obj in self {
            result = combine(result, obj)
        }
        
        return result
    }
}

func concatenateWithSpace(result: String, text: String) -> String {
    // if first time return the text
    return (result == "") ? text : result + " " + text
}


let strings    = ["This", "is", "a", "text"]
let fullString = strings.reduce("") { x, y in concatenateWithSpace(x, text: y) }
fullString // " This is a text"
/*:
Ok, what just happend!?

Don't worry, let's go through this step by step. When using reduce we always need to pass an initial value,
this way we can guarantee that the result will be correctly initialized and have something to return
in case nothing happens inside your loop.
Since we are combining the results to generate one final result we need to pass the current result each time
the loop runs, that's why we declare combine passing 2 arguments. The function we are passing along the method
just concatenate a new value each time the loop runs, adding a space in between the words.

How about map, filter and reduce an array of **Ints**? It can be done!
*/
let reducedValues =
    values.map { x in addOne(x) }
    .filter { x in x % 3 == 0 }
    .reduce(0) { result, currentValue in result + currentValue }
reducedValues // 900 (3 + 6 + 891)
/*:
Now, step by step:
* first we go through the values array and add +1 to each element,
* then we filter it by getting only the values that are divisible by 3
* and finally we sum all these values.

Using functional concepts in swift elevates the language to whole
new level. It's powerful, plus you can get rid off those ugly for-loops
all over your code :). At this point you will be ready to try a few
ideas yourself, don't forget swift already have these operations
built-in, so go right to your code and have fun. If you have any
questions or comments, just drop me a message at @colatusso. Cheers!

### 4. appendix

What about using map with dictionaries?
Let's get a dictionary of **[city: population]** and try to add 10%
more people in each city by using map.
Don't worry about the **"Value -> T"**. Since in a dictionary we
have a **Key: Value** pair, we are just expliciting that the value
passed in the argument is the **Value** part of the pair, and the
result will be of any type(**T**).
*/
extension Dictionary {
    func map<T>(transform: Value -> T) -> Dictionary<Key, T> {
        var result = Dictionary<Key, T>()
        
        for obj in self {
            // the key is .0 and the value .1
            result[obj.0] = transform(obj.1)
        }
        
        return result
    }
}

func addTenPorcent(value:Int) -> Int {
    // it's Int * Double
    // so we have to cast
    return Int(Double(value) * 1.1)
}

let population = ["City 1": 1000, "City 2": 6000, "City 3": 2500, "City 4": 4000]
var mappedDict = population.map { value in addTenPorcent(value) }
mappedDict // "City 1": 1100, "City 2": 6600, "City 3": 2750, "City 4": 4400
/*:
Ok, let's say we want to select only cities with less than 3000 people
in order to add those extra 10%. We can filter and than map it.
*/
extension Dictionary {
    func filter(check: Value -> Bool) -> Dictionary<Key, Value> {
        var result = Dictionary<Key, Value>()
        
        for obj in self where check(obj.1) {
            result[obj.0] = obj.1
        }
        
        return result
    }
}

mappedDict = population.filter { value in value < 3000 }
    .map { value in addTenPorcent(value) }

mappedDict // "City 1": 1100, "City 3": 2750
