@testset "Test configuring calendar" begin
    calfile = joinpath(pwd(), "data", "calendar1.toml")    
    config = TOML.parsefile(calfile)
    expectedfirst = Date("2022-08-31")
    @test Date(config["firstDay"]) == expectedfirst


    schedule = courseSchedule(calfile)
    @test schedule isa CourseSchedule
end