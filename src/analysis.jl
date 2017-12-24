"""
  Given a recipe and Flavornet object, return a matrix of common flavor counts for the ingredients of the recipe
  """
function affinities(recipe::Vector{String}, fn::Flavornet)
  idx = [fn.index[recipe[i]] for i in eachindex(recipe)]
  Matrix(fn.W[idx,idx])
end

"""
  Return a Vector of all ingredients in a Vector of recipes (each a Vector of ingredients.)
  """
function all_ingredients(recipes::Vector{Vector{String}})
  ans = Vector{String}(0)
  for recipe in recipes
    ans = unique(vcat(ans,recipe))
  end
  return ans
end

"""
  For each cuisine in the given dictionary of world recipes, return a list of all ingredients for each.
  """
function all_ingredients(cuisines::Dict{String,Vector{Vector{String}}})
  ans = Dict{String,Vector{String}}()
  for key in keys(cuisines)
    ans[key]=all_ingredients(cuisines[key])
  end
  return ans
end

"""
  Given a dictionary of ingredients, return a Matrix of pairwise fractional overlap, i.e., the size of their intersection divided by the size of their union.
  """
function fractional_overlap(cuisine_ingredients::Dict{String,Vector{String}})
  k = collect(keys(cuisine_ingredients))
  ans = Matrix{Float64}(length(k),length(k))
  for i in eachindex(k)
    for j in 1:i
      a = cuisine_ingredients[k[i]]
      b = cuisine_ingredients[k[j]]
      ans[i,j]=ans[j,i]=length(intersect(a,b))/length(union(a,b))
    end
  end
  return ans
end

#= cruft
"""
  Given a Flavornet object and parameter k, apply k-means clustering to W returning the result and a list of ingredients assigned to each cluster.
  """
function apply_kmeans(fn::Flavornet, k::Int)
  R = Clustering.kmeans(Matrix{Float64}(fn.W),k)
  content = Vector{Vector{String}}(k)
  for i in 1:k
    content[i] = [fn.ingredients[j] for j in eachindex(fn.ingredients) if R.assignments[j]==i]
  end
  return R, content
end

""" dffind(df, value, column)

  Return the row(s) of a DataFrame, df,  with the specified `value` in the named `column`.
  """
function dffind{T}(df::DataFrame, value::T, column::Symbol)
  df[df[column].==value,:]
end
=#
