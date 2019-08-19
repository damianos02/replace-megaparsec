{-# LANGUAGE FlexibleContexts #-}

module Tests ( tests ) where

import Distribution.TestSuite
import Parsereplace
import Text.Megaparsec
import Text.Megaparsec.Char
import Data.Void
import Data.Scientific

type Parser = Parsec Void String

tests :: IO [Test]
tests = return
    [ Test $ runParserTest "findAll upperChar"
        (findAll (upperChar :: Parser Char))
        ("aBcD" :: String)
        [Left "a", Right ("B", 'B'), Left "c", Right ("D", 'D')]
    , Test $ runParserTest "zero-consumption parser"
        (sepCap (many (upperChar :: Parser Char)))
        ("aBcD" :: String)
        [Left "a", Right "B", Left "c", Right "D"]
    , Test $ runParserTest "scinum"
        (sepCap scinum)
        ("1E3")
        ([Right (1,3)])
    , Test $ runParserTest "getOffset"
        (sepCap offsetA)
        ("xxAxx")
        ([Left "xx", Right 2, Left "xx"])
    ]

runParserTest name p input expected = TestInstance
        { run = do
            case runParser p "" input of
                Left e -> return (Finished $ Fail $ show e)
                Right output ->
                    if (output == expected)
                        then return (Finished Pass)
                        else return (Finished $ Fail
                                    $ show output ++ " ≠ " ++ show expected)
        , name = name
        , tags = []
        , options = []
        , setOption = \_ _ -> Left "no options supported"
        }

scinum :: Parser (Double, Integer)
scinum = do
    m <- some digitChar
    string "E"
    e <- some digitChar
    return (read m, read e)


offsetA :: Parser Int
offsetA = do
    offset <- getOffset
    string "A"
    return offset

