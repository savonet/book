x = ""
# header
s = if x == "a" then 0
    else
      if x == "b" then 1
      else
        if x == "c" then 2
        else 3 end
      end
    end
# footer
ignore(s)
