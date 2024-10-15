if fs.exists("./filename.lua") then
    fs.delete("./filename.lua")
end

shell.execute("wget", "https://raw.githubusercontent.com/feylostt/lucky-lady/refs/heads/main/src/path")
shell.run("filename")