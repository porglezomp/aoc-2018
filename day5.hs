import Data.Char (toLower, isSpace)
import Data.Set (Set)
import qualified Data.Set as Set

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

fixed :: Eq a => (a -> a) -> a -> a
fixed f x = let y = f x in
    if y == x then y else fixed f y

main :: IO ()
main = do
  polymer <- filter (not . isSpace) <$> getContents
  print . length $ fixed react polymer
  let units = foldl (flip (Set.insert . toLower)) Set.empty polymer
  print . minimum $ [length $ fixed react p |
                     u <- Set.toList units,
                     let p = filter ((/= u) . toLower) polymer]
