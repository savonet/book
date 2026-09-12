#!./liquidsoap
x =
  try
    list.hd([])
  catch err : [error.not_found] do
    print("caught the error #{err.kind}: #{err.message}")
    0
  finally
    print("we are done with the list")
  end
print(string(x))
