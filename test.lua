local Kernel = require('./kernel')
local Timer = require('timer')
local UV = require('uv')
local Table = require('table')
Kernel.cache_lifetime = 0 -- disable cache

Kernel.helpers = {
  PARTIAL = function (name, locals, callback)
    Kernel.compile(name, function (err, template)
      if err then return callback(err) end
      template(locals, callback)
    end)
  end,
  IF = function (condition, block, callback)
    if condition then block({}, callback)
    else callback(nil, "") end
  end,
  LOOP = function (array, block, callback)
    local left = 0
    local parts = {}
    local done
    for i, value in ipairs(array) do
      left = left + 1
      value.index = i
      block(value, function (err, result)
        if done then return end
        if err then
          done = true
          callback(err)
          return
        end
        parts[i] = result
        left = left - 1
        if left == 0 then
          done = true
          callback(null, Table.concat(parts))
        end
      end)
    end
  end
}

Kernel.compile("tasks.html", function (err, template)
  if err then p("error",err); return end
  local data = {
    name = "Tim Caswell",
    tasks = {
      {task = "Program Awesome Code"},
      {task = "Play with Kids"},
      {task = "Answer Emails"},
      {task = "Write Blog Post"},
    }
  }
  template(data, function (err, result)
    p(err, result)
  end)
end)


