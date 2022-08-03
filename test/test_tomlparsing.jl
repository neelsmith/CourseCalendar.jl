@testset "Test configuring calendar" begin
    calfile = joinpath(pwd(), "data", "calendar1.toml")    
    topicsfile = joinpath(pwd(), "data", "topics1.txt")

    config = TOML.parsefile(calfile)
    expectedfirst = Date("2022-08-31")
    @test Date(config["firstDay"]) == expectedfirst


    schedule = courseSchedule(calfile, topicsfile)
    @test schedule isa CourseSchedule
end