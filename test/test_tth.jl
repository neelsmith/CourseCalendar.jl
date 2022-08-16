
@testset "Test TuesThurs calendar" begin
    calfile = joinpath(pwd(), "data", "tth_pattern", calendar1.toml")    
    topicsfile = joinpath(pwd(), "data", "tth_pattern", "topics1.txt")

    config = TOML.parsefile(calfile)
end
   