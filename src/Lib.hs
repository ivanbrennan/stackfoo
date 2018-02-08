module Lib (helloWorld, unused) where

helloWorld :: IO ()
helloWorld = putStrLn "helloWorld"

unused :: Char
unused = undefined
