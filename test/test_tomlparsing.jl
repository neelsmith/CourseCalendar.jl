@testset "Test configuring calendar" begin
    calfile = joinpath(pwd(), "test", "data", "calendar1.toml")    
    config = TOML.parsefile(calfile)
    expectedfirst = Date("2022-08-31")
    Date(config[firstDay]) == expectedfirst

end