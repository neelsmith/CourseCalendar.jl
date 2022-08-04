

"""Assemble Sunday-Saturday week range encompassing `d`.
"""
function weekrange(d::Date)
    beginday = d - Dates.Day(dayofweek(d))
    endoffset =    6 - dayofweek(d)
    endday = d + Dates.Day(endoffset)
    beginday:Day(1):endday |> collect
end
