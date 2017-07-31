
thisdir = dirname(@__FILE__())

function read_flavornet()
  readtable(joinpath(thisdir,"data","srep00196-s2.csv"),
                        allowcomments=true,header=false,eltypes=[String,String,Int])
end

immutable Flavornet
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

function reduce_recipe(df::DataFrames.DataFrame, row::Int; itr=2:size(df,2))
  [df[row,i] for i in itr if typeof(df[row,i])==String]
end

immutable Recipes
  world::Dict{String,Vector{Vector{String}}}
  regions::Vector{String}
  
  function Recipes()
    rcp = read_recipes()
    itr = 2:size(rcp,2)
    world = Dict{String,Vector{Vector{String}}}()
    regions = unique(rcp[:,1])
    for region in regions
      tmp = rcp[rcp[:,1].==region,:]
      world[region] = [reduce_recipe(tmp,i,itr=itr) for i in 1:size(tmp,1)]
    end
    new(world,regions)
  end
    
end

