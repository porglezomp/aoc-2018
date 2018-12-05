import Data.Char (toLower, isSpace)
import Data.Set (Set)
import qualified Data.Set as Set

{-
Observation: you can avoid iterating this to a fixed point, since it
will always react fully on the first pass. If you react something of
the form abBA, then it will skip one, and react bBA, leaving A, then
it will move back one, and reactHead on aA, completing the reaction.
This argument can be continued by induction, since if there is further
wrapping, the inner reaction will have finished by the time you make it
back to the point you were at. This, we don't have to iterate to a
fixed point, which saves some time checking if you need to repeat.
-}

canReact :: Char -> Char -> Bool
canReact x y = toLower x == toLower y && x /= y

reactHead :: String -> String
reactHead (y : x : xs)
  | canReact y x = xs
  | otherwise = y : x : xs
reactHead xs = xs

react :: String -> String
react (y : x : xs)
  | canReact y x = react xs
  | otherwise = reactHead (y : react (x : xs))
react xs = xs

main :: IO ()
main = do
  polymer <- filter (not . isSpace) <$> getContents
  print . length $ react polymer
  let units = foldl (flip (Set.insert . toLower)) Set.empty polymer
  print . minimum $ [length $ react p |
                     u <- Set.toList units,
                     let p = filter ((/= u) . toLower) polymer]

