using CSV, DataFrames

df = DataFrame(CSV.File("./countries-table.csv"));
select!(df, [:country, :rank, :density]);

using Gadfly
p = plot(df, y=:density, x=:rank, color=:country);
img = SVG("20230629.svg", 12inch, 3inch);
draw(img, p);
