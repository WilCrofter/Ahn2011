
thisdir = dirname(@__FILE__())

function read_flavornet()
  readtable(joinpath(thisdir,"data","srep00196-s2.csv"),
                        allowcomments=true,header=false,eltypes=[String,String,Int])
end

type Flavornet
  ingredients::Vector{String}
  index::Dict{String,Int}
  W::SparseMatrixCSC{Int64,Int64}
  
  function Flavornet()
    tbl = read_flavornet()
    ingredients = unique(vcat(Vector(tbl[:,1]),Vector(tbl[:,2])))
    index = Dict{String,Int}()
    for i in eachindex(ingredients)
      index[ingredients[i]]=i
    end
    n=size(tbl,1)
    I=Vector{Int}(n)
    J=Vector{Int}(n)
    V=Vector{Int}(n)
    for i in 1:n
      I[i]=index[tbl[i,1]]
      J[i]=index[tbl[i,2]]
      V[i]=tbl[i,3]
    end
    W = sparse(vcat(I,J),vcat(J,I),vcat(V,V))
    new(ingredients,index,W)
  end
  
end

function read_recipes()
  readtable(joinpath(thisdir,"data","srep00196-s3.csv"), allowcomments=true,header=false)
end

function neighbors(ingredient::String, flavornet::DataFrames.DataFrame)
  tmp1 = flavornet[flavornet[:,1].==ingredient, [2,3]]
  tmp2 = flavornet[flavornet[:,2].==ingredient, [1,3]]
  ans = hcat(vcat(tmp1[1],tmp2[1]), vcat(tmp1[2],tmp2[2]))
  return ans[sortperm(ans[:,2], rev=true),:]
end

function hasthispair(ingredient1::String, ingredient2::String, k::Int, flavornet::DataFrames.DataFrame)
  (flavornet[k,1]==ingredient1 && flavornet[k,2]==ingredient2) ||
    (flavornet[k,1]==ingredient2 && flavornet[k,2]==ingredient1)
end

function pairing(ingredient1::String, ingredient2::String, flavornet::DataFrames.DataFrame)
  flavornet[[i for i in 1:size(flavornet,1) if hasthispair(ingredient1,ingredient2,i)],:]
end

function ingredients(recipe::Int, recipes::DataFrames.DataFrame)
  tmp = recipes[recipe,:]
  return [tmp[i][1] for i in 1:size(tmp,2) if typeof(tmp[i][1])==String]
end

