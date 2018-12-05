import Data.Char (toLower, isSpace)
import Data.Set (Set)
import qualified Data.Set as Set

data Zipper a = Zip [a] [a]

zipLength :: Zipper a -> Int
zipLength (Zip xs ys) = length xs + length ys

reactSkip :: Char -> Zipper Char -> Zipper Char
reactSkip c (Zip (x : xs) (y : ys))
  | toLower y == c = reactSkip c (Zip (x : xs) ys)
  | canReact y x = reactSkip c (Zip xs ys)
  | otherwise = reactSkip c (Zip (y : x : xs) ys)
    where canReact x y = toLower x == toLower y && x /= y
reactSkip c (Zip [] (y : ys))
  | toLower y == c = reactSkip c (Zip [] ys)
  | otherwise = reactSkip c (Zip [y] ys)
reactSkip _ (Zip xs []) = Zip xs []

main :: IO ()
main = do
  polymer <- filter (not . isSpace) <$> getContents
  let units = foldl (flip (Set.insert . toLower)) Set.empty polymer
  let polymer' = Zip [] polymer
  print . zipLength $ reactSkip ' ' polymer'
  print . minimum $ [zipLength $ reactSkip u polymer' | u <- Set.toList units]

