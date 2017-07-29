
thisdir = dirname(@__FILE__())

function readFN()
  fname = joinpath(thisdir,"data","srep00196-s2.csv")
  return readtable(fname, allowcomments=true,header=false,eltypes=[String,String,Int])
end

""" loadFN()

  Return a sparse matrix, W, with index labels, V, representing ingredients where W[i,j] represents the number of flavors V[i] and V[j] have in common. Data is derived from supplementary information associated with Ahn, et. al., [Flavor network and the principles of food pairing](https://www.nature.com/articles/srep00196) Scientific Reports 1, Article number: 196 (2011) doi:10.1038/srep00196, which is licensed under a [Creative Commons Attribution-NonCommercial-ShareALike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/). 
  """
function loadFN()
  tbl = readFN()
  n = size(tbl,1)
  V = sort!(unique(vcat(Vector(tbl[:,1]),Vector(tbl[:2]))))
  I::Vector{Int} = [findfirst(V,tbl[i,1]) for i in 1:n]
  J::Vector{Int} = [findfirst(V,tbl[i,2]) for i in 1:n]
  W::Vector{Int} = [tbl[i,3] for i in 1:n]
  M = sparse(I,J,W)
  for k in eachindex(tmp)
    i,j = k[1],k[2]
    M[i,j]=M[j,i]=max(M[i,j],M[j,i])
  return sparse(I,J,W), V
end


function readRCP()
  fname = joinpath(thisdir,"data","srep00196-s3.csv")
  return readtable(fname, allowcomments=true,header=false)
end

function reducedRow(df::DataFrames.DataFrame, row::Int)
  v = Vector{String}(size(df,2))
  n = 0
  for i in 1:size(df,2)
    if typeof(df[row,i])==String
      n +=1
      v[n]=df[row,i]
    end
  end
  return v[1:n]
end
