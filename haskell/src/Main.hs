module Main where

import Main.Utf8 qualified as Utf8

import Foreign.C.Types

foreign import ccall "double_input" doubleInput :: CInt -> CInt

{- |
 Main entry point.

 The `bin/run` script will invoke this function. See `.ghcid` file to change
 that.
-}
main :: IO ()
main = do
  Utf8.withUtf8 $ do
    putStrLn "Haskell: Hello 🌎"
    print $ doubleInput 21
