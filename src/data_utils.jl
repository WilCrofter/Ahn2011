
thisdir = dirname(@__FILE__())

flavornet = readtable(joinpath(thisdir,"data","srep00196-s2.csv"),
                        allowcomments=true,header=false,eltypes=[String,String,Int])

recipes = readtable(joinpath(thisdir,"data","srep00196-s3.csv"), allowcomments=true,header=false)


function neighbors(ingredient::String)
  tmp1 = flavornet[flavornet[:,1].==ingredient, [2,3]]
  tmp2 = flavornet[flavornet[:,2].==ingredient, [1,3]]
  ans = hcat(vcat(tmp1[1],tmp2[1]), vcat(tmp1[2],tmp2[2]))
  return ans[sortperm(ans[:,2], rev=true),:]
end
