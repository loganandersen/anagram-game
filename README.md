# anagram-game
Command line anagram game
# Requriments
Requires guile 3.0

# Installation
Move the anagram-game.scm to a path folder and then give it execute permissions.

# behavior
This game will let you create anagrams different from the scrambled word so long as it's in the dictionary file. 

For instance bemscral has scramble and clambers as different anagrams.

# Example game
```
$ anagram-game /usr/share/dict/words 
moidetzor
> zoidmoert
incorrect, (answer was: motorized)
sushu'pp
> pushup's 
correct, (answer was: pushup's)
esnrabtirea
> earnartriba
incorrect, (answer was: brainteaser)

```
as you can see I am fairly bad at the game.
