import Data.Char (toLower, isSpace)

react :: String -> String
react (y : x : xs)
  | toLower x == toLower y && x /= y = react xs
  | otherwise = y : react (x : xs)
react xs = xs

fixed :: Eq a => (a -> a) -> a -> a
fixed f x = let y = f x in
    if y == x then y else fixed f y

main :: IO ()
main = do
  text <- filter (not . isSpace) <$> getContents
  print . length $ fixed react text
