using DEIM
using Documenter

DocMeta.setdocmeta!(DEIM, :DocTestSetup, :(using DEIM); recursive=true)

makedocs(;
    modules=[DEIM],
    authors="Flemming Holtorf",
    repo="https://github.com/FHoltorf/DEIM.jl/blob/{commit}{path}#{line}",
    sitename="DEIM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://FHoltorf.github.io/DEIM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/FHoltorf/DEIM.jl",
    devbranch="main",
)
