using CSV
using DataFrames
using Gadfly
using Cairo, Fontconfig # for PNG


# Todo:
# [] Make better constructor (more correct)
# [] Macros for line 86



# - 
# Struct to keep track of stuff easier
# -

mutable struct dual_list{T}
  l1::Vector{T}
  l1_name::String
  l2::Vector{T}
  l2_name::String
end

# Bad Constructor!!
function new_dual_list(name1::String, name2::String, type::Type=Int)
  dual_list(Vector{type}(), name1, Vector{type}(), name2)
end

# Methods for dual_list
function get(dl::dual_list, word::String, el::Int=-1)

  if (el == -1)
    if (word == dl.l1_name)
      return dl.l1
    elseif (word == dl.l2_name)
      return dl.l2
    end
  end


  if (word == dl.l1_name)
    return dl.l1[el]
  elseif (word == dl.l2_name)
    return dl.l2[el]
  else
    error("Given List Name `$el_name` does not exist in the dual_list")
  end
end

function extend_list!(list::Vector, el::Int)
    if (el > length(list))
      while (el > length(list))
        push!(list, 0)
      end
    end
end

function update_list!(dl::dual_list, el_name::String, el::Int)
  if (el_name == dl.l1_name)

    extend_list!(dl.l1, el)
    dl.l1[el] += 1

  elseif (el_name == dl.l2_name)
    extend_list!(dl.l2, el)
    dl.l2[el] += 1
  else
    error("Given List Name `$(el_name)` does not exist")
  end

end

# - 
# Make Dataframe!
# - 

# to keep line 86 cleaner, maybe make a macro to optimize?
gwp_format(el) = parse(Int, split(el, " ")[end]) - 1

og_df = DataFrame(CSV.File("warriorsceltics.csv"))
df = DataFrame()
df_dual_list = new_dual_list("Warriors", "Celtics")

# Get the info we needddddd
df[!, "winning_team"] = [split(el, " ")[1] for el in og_df.Streak]
df[!, "games_won_previous"] = [gwp_format(el) for el in og_df.Streak]

# Convert the df to dual_list (NOTE: index = 1 + number of games won previous)
for row in eachrow(df)
  update_list!(df_dual_list, String(row.winning_team), row.games_won_previous + 1)
end

warriors_total = sum(get(df_dual_list, "Warriors"))
celtics_total = sum(get(df_dual_list, "Celtics"))

warriors_percentages = [(el / warriors_total) * 100 for el in get(df_dual_list, "Warriors")]
celtics_percentages = [(el / celtics_total) * 100 for el in get(df_dual_list, "Celtics")]

# @show warriors_percentages
# @show celtics_percentages

# println(df_dual_list)

h2 = plot(layer(x=1:length(warriors_percentages), y=warriors_percentages, color=["red"]),
  layer(x=1:length(celtics_percentages), y=celtics_percentages, color=["blue"]))

p1 = plot(x=1:length(warriors_percentages), y=warriors_percentages)
p2 = plot(x=1:length(celtics_percentages), y=celtics_percentages)
h1 = hstack(p1, p2)

img = PNG("iris_plot.png", 12inch, 6inch)
draw(img, h2)
