module FlavorData

export compound_ids, ingredient_ids, ingredient_compounds, cuisines

thisdir = dirname(@__FILE__())

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

""" ingredient_compounds()

    Returns a sparse incidence (0 or 1)  matrix, M, where M[i,j] = 1 if ingredient i contains compound j and M[i,j]=0 otherwise. Row indices match row indices of ingredient information as returned by ingredient_ids(). Column indices match row indices of compound information  as returned by compound_ids().
    """
function ingredient_compounds()::SparseMatrixCSC{Int,Int}
    tmp = readdlm(joinpath(thisdir,"data/ingr_comp.tsv"),Int)+1 # +1 for 1-origin conversion
    return sparse(tmp[:,1],tmp[:,2],1)
end

""" cuisines()
    
    Returns a dictionary of local "cuisines" indexed by region. Each "cuisine" is a sparse incidence (0 or 1) matrix in which each row represents a recipe and each column represents an ingredient. Column indices match the row indices of ingredient names as returned by ingredient_ids().
    """
function cuisines()::Dict{String,SparseMatrixCSC{Int,Int}}
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
    regions = unique(rawdata[:,1])
    ans = Dict{String,SparseMatrixCSC{Int,Int}}()
    for c in regions
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

end
