import Data.Char (toLower, isSpace)
import Data.Set (Set)
import qualified Data.Set as Set

data Zipper a = Zip [a] [a]

zipLength :: Zipper a -> Int
zipLength (Zip xs ys) = length xs + length ys

react :: Zipper Char -> Zipper Char
react (Zip (x : xs) (y : ys))
  | canReact y x = react (Zip xs ys)
  | otherwise = react (Zip (y : x : xs) ys)
    where canReact x y = toLower x == toLower y && x /= y
react (Zip [] (y : ys)) = react (Zip [y] ys)
react (Zip xs []) = Zip xs []

main :: IO ()
main = do
  polymer <- filter (not . isSpace) <$> getContents
  print . zipLength . react $ Zip [] polymer
  let units = foldl (flip (Set.insert . toLower)) Set.empty polymer
  print . minimum $ [zipLength $ react (Zip [] p) |
                     u <- Set.toList units,
                     let p = filter ((/= u) . toLower) polymer]

