
thisdir = dirname(@__FILE__())

""" loadFN()

  Return a sparse matrix, W, with index labels, V, representing ingredients where W[i,j] represents the number of flavors V[i] and V[j] have in common. Data is derived from supplementary information associated with Ahn, et. al., [Flavor network and the principles of food pairing](https://www.nature.com/articles/srep00196) Scientific Reports 1, Article number: 196 (2011) doi:10.1038/srep00196, which is licensed under a [Creative Commons Attribution-NonCommercial-ShareALike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/). 
  """
function loadFN()
  fname = joinpath(thisdir,"data","srep00196-s2.csv")
  tbl=readtable(fname, allowcomments=true,header=false,eltypes=[String,String,Int])
  n = size(tbl,1)
  V = sort!(unique(vcat(Vector(tbl[:,1]),Vector(tbl[:2]))))
  I::Vector{Int} = [findfirst(V,tbl[i,1]) for i in 1:n]
  J::Vector{Int} = [findfirst(V,tbl[i,2]) for i in 1:n]
  W::Vector{Int} = [tbl[i,3] for i in 1:n]
  return sparse(I,J,W), V
end


function loadRCP()
  fname = joinpath(thisdir,"data","srep00196-s3.csv")
  readtable(fname, allowcomments=true,header=false)
end
