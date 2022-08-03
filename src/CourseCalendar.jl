module CourseCalendar
using CitableBase
using Dates
using TOML

export CourseSchedule, courseSchedule



include("courseschedule.jl")
include("events.jl")
include("topics.jl")

end # module
