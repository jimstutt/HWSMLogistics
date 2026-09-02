{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.IO as T

main :: IO ()
main = do
    T.putStrLn "<!DOCTYPE html>"
    T.putStrLn "<html><head><title>NGO Logistics</title>"
    T.putStrLn "<style>body{font-family:sans-serif;margin:0;}nav{width:110px;background:#f4f4f4;height:100vh;position:fixed;padding:20px;}main{margin-left:130px;padding:20px;}.modal{display:none;position:fixed;top:20%;left:30%;background:white;padding:20px;border:1px solid #ccc;}</style>"
    T.putStrLn "</head><body>"
    T.putStrLn "<nav><h3>Menu</h3><ul><li><a href='#dashboard'>Dashboard</a></li><li><a href='#shipments'>Shipments</a></li><li><a href='#delivery'>Delivery Notes</a></li><li><a href='#reports'>Reports</a></li><li><a href='#admin'>Admin</a></li></ul></nav>"
    T.putStrLn "<main>"
    T.putStrLn "<div id='login-modal' class='modal' style='display:block;'><h2>Login</h2><input id='email' placeholder='Email'/><input id='password' type='password' placeholder='Password'/><button onclick='login()'>Login</button></div>"
    T.putStrLn "<div id='app' style='display:none;'><h1>Dashboard</h1><div id='map' style='height:400px;background:#eee;'>Map Placeholder</div></div>"
    T.putStrLn "</main>"
    T.putStrLn "<script>function login(){document.getElementById('login-modal').style.display='none';document.getElementById('app').style.display='block';}</script>"
    T.putStrLn "</body></html>"
