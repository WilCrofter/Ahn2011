
thisdir = dirname(@__FILE__())

""" ingredient_compounds()

    Returns a sparse integer matrix, M, where M[i,j] = 1 if ingredient i contains compound j and M[i,j]=0 otherwise.
    """
function ingr_comp()::SparseMatrixCSC{Int,Int}
    tmp = readdlm(joinpath(thisdir,"data/ingr_comp.tsv"),Int)+1 # +1 for 1-origin conversion
    return sparse(1+tmp[:,1],1+tmp[:,2],1)
end

""" compound_ids()

    Returns a 2-column array, A, of Strings in which A[i,1] is the name of compound i and A[i,2] is its [CAS number](https://en.wikipedia.org/wiki/CAS_Registry_Number).
    """  
function compound_ids()::Array{String,2}
    return readdlm(joinpath(thisdir,"data/comp_info.tsv"),String)[:,2:3]
end


""" ingredient_ids()

    Returns a 2-column array, A, of Strings in which A[i,1] is the name of ingredient i and A[i,2] is its food category, e.g., meat, fish/seafood, plant, herb...
    """
function ingredient_ids()::Array{String,2}
    return readdlm(joinpath(thisdir,"data/ingr_info.tsv"),String)[:,2:3]
end

function recipes()::Dict{String,SparseMatrixCSC{Int,Int}}
    rawdata = readdlm(joinpath(thisdir,"data/srep00196-s3.csv"),',',String)
    idx, icount = begin
        n,m = size(rawdata)
        # Unique ingredients after removing cuisine and blank entries
        unique_ingr = setdiff(unique(reshape(rawdata[:,2:end], n*(m-1))),[""])
        # ingredient ids
        ids = ingredient_ids()
        # Dictionary relating ingredient names to their indices
        tmp = Dict{String,Int}()
        for ingr in unique_ingr
            tmp[ingr]=find(ids[:,1].==ingr)[1]
        end
        tmp, size(ids,1)
    end
    cuisines = unique(rawdata[:,1])
    ans = Dict{String,SparseMatrixCSC{Int,Int}}()
    for c in cuisines
        rcp = rawdata[rawdata[:,1].==c,2:end]
        ecount = sum(rcp.!="")
        Is = zeros(Int,ecount)
        Js = zeros(Int,ecount)
        n = 0
        for i in 1:size(rcp,1)
            tmp = setdiff(rcp[i,:],[""])
            for ingredient in tmp
                n += 1
                Is[n] = i
                Js[n] = idx[ingredient]
            end
        end
        ans[c] =sparse(Is[1:n],Js[1:n],1,size(rcp,1),icount)
    end
    return ans
end

#=
# Read raw data into DataFrames

"""
  Reads srep00196-s2.csv into a DataFrame with columns :name1, :name2, and :common_flavors. The first two columns name pairs of ingredients, the third gives the number of common flavor compounds.
  """
function read_flavornet()
  readtable(joinpath(thisdir,"data","srep00196-s2.csv"),
                        allowcomments=true,header=false,eltypes=[String,String,Int],names=[:name1, :name2, :common_flavors])
end

function reduce_recipe(df::DataFrames.DataFrame, row::Int; itr=2:size(df,2))
  [df[row,i] for i in itr if typeof(df[row,i])==String]
end

function read_recipes()
  raw=readtable(joinpath(thisdir,"data","srep00196-s3.csv"), allowcomments=true,header=false)
  df = DataFrames.DataFrame()
  df[:region] = raw[:,1]
  df[:recipe] = [reduce_recipe(raw, i) for i in 1:size(raw,1)]
  return df
end

"""
  Reads ingr_info.tsv into a DataFrame with columns :id,  :name, and :category, examples of the last being meat, plant, plant derivative etc. The first two columns respectively give a unique id and recognizable name of various ingredients.
  """
function read_ingr_info()
  readtable(joinpath(thisdir,"data","ingr_info.tsv"),
            allowcomments=true,header=false,eltypes=[Int,String,String],names=[:id, :name, :category])
end

=#

#= Vestigial cruft

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

  function Flavornet(fn::Flavornet,ingredients::Vector{String})
    ingredients=sort(intersect(ingredients,fn.ingredients))
    index = Dict{String,Int}()
    for i in eachindex(ingredients)
      index[ingredients[i]]=i
    end
    tmp = [fn.index[i] for i in ingredients]
    W = deepcopy(fn.W[tmp,tmp])
    new(ingredients, index, W)
  end
  
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



function categories()
  tbl = read_ingr_info()
  ans = Dict{String,String}()
  for rw in eachrow(tbl)
    ans[rw[:x2]] = rw[:x3]
  end
  ans
end
=#
