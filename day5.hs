import Control.Monad.State.Strict (State, get, put, runState)
import Data.Char (toLower, isSpace)
import Data.Set (Set)
import qualified Data.Set as Set

canReact :: Char -> Char -> Bool
canReact x y = toLower x == toLower y && x /= y

reactHead :: String -> State Bool String
reactHead (y : x : xs)
  | canReact y x = put True *> pure xs
  | otherwise = pure $ y : x : xs
reactHead xs = pure xs

react :: String -> State Bool String
react (y : x : xs)
  | canReact y x = react xs <* put True
  | otherwise = react (x : xs) >>= reactHead . (y :)
react xs = pure xs

fixed :: (a -> State Bool a) -> a -> a
fixed f x =
    let (y, changed) = runState (f x) False in
    if changed then fixed f y else y

main :: IO ()
main = do
  polymer <- filter (not . isSpace) <$> getContents
  print . length $ fixed react polymer
  let units = foldl (flip (Set.insert . toLower)) Set.empty polymer
  print . minimum $ [length $ fixed react p |
                     u <- Set.toList units,
                     let p = filter ((/= u) . toLower) polymer]
