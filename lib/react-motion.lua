--[[
  Motion.p8
  This library tries to implement the most relevant features of the React
  Motion library for Pico-8.
  See the original library here: https://motion.dev/
  The library assumes that the React library is already included.
]]

--[[
  TODOs:
  - Support `useSpring`. Like `useSpring(0, { stiffness: 300 })`
    - See https://motion.dev/docs/react-use-spring#transition
    - See https://motion.dev/docs/react-transitions#spring
  - Support `useTransition`. Linear?, bezier?, frame-by-frame value array?
  - Support AnimatePresence.
  - Like Motion.Div, etc., support Motion wrappers for drawing functions.
    I.e. components that accept `initial`, `animate`, and `exit` props to
    animate draw function args.
    - Support all drawing functions: pset, sset, fset, print, cursor, color,
      cls, camera, circ, circfill, oval, ovalfill, line, rect, rectfill, pal,
      palt, spr, sspr, fillp, mset, map, tline.
    - Possible big brain: Consider making a single Motion component that just
      takes the drawing function as input as well as `initial`, `animate`, and
      `exit`.
      - Usage could look like:
          return { Motion, rect, {
            initial: { 0, 0, 10, 10 },
            animate: { 10, 10, 20, 20 },
            exit: { 20, 20, 30, 30 }
          } }
      - At second glance, would we really want motion rect in the output?
        There's no HTML forcing us to do this. We could implement the Motion
        component as a useMotion hook instead. This could look like:
          useMotion(rect, {
            initial: { 0, 0, 10, 10 },
            animate: { 10, 10, 20, 20 },
            exit: { 20, 20, 30, 30 }
          })
      - Pros for a Motion component over useMotion:
        - Can idiomatically be passed to components as children.
          - (But I guess this point is moot, isn't the question, what should be
            idiomatic?)
        - Keeping rendering to the output of the component, rather than
          rendering in a hook, might make react.p8 code more readable in the
          long run.
      - Pros for useMotion over a Motion component:
        - Can be composed in hooks.
        - Might be more performant than a component?
  - Possibly implement useContext in react.p8, and use that to set default
    animation settings, like spring config.
]]

function __initMotion()
  local SpringConfigContext = createContext({
    stiffness = 100,
    damping = 10,
    mass = 1
  })

  -- Helper function to calculate the next state of the spring
  local function calculateSpringState(stiffness, damping, mass, target, position, velocity, dt)
    local displacement = position - target
    local acceleration = (-stiffness * displacement - damping * velocity) / mass
    local newVelocity = velocity + acceleration * dt
    local newPosition = position + newVelocity * dt
    return newPosition, newVelocity
  end

  local function useSpring(animate, initial)
    -- TODO: Rename to useSprings
    -- TODO: support single animate number argument for singular spring, or add useSpring alongside useSprings.
    assert(type(animate) == "table", "animate must be an array of function arguments.")

    local state = useState(function()
      return {
        targetPositions = animate,
        currentPositions = initial or animate,
        currentVelocities = {}
      }
    end)

    assert(#state.currentPositions == #animate, "animate must have the same length as the current state.")

    state.targetPositions = animate

    local springConfig = useContext(SpringConfigContext)

    for i, targetPosition in ipairs(state.targetPositions) do
      local newPos, newVel = calculateSpringState(
        springConfig.stiffness,
        springConfig.damping,
        springConfig.mass,
        targetPosition,
        state.currentPositions[i],
        state.currentVelocities[i] or 0,
        1 / 60
      )
      state.currentPositions[i] = newPos
      state.currentVelocities[i] = newVel
    end

    return state.currentPositions, state.currentVelocities
  end

  local function useTransition()
    assert(false, "useTransition is not implemented yet.")
  end

  local function AnimatePresence()
    assert(false, "AnimatePresence is not implemented yet.")
  end

  local function Motion(drawFunc, animate, initial)
    assert(type(drawFunc) == "function", "drawFunc must be a function.")
    assert(type(animate) == "table", "animate must be an array of function arguments.")

    local currentArgs = useSpring(animate, initial)

    drawFunc(unpack(currentArgs))
  end

  return useSpring, useTransition, AnimatePresence, Motion
end

local useSpring, useTransition, AnimatePresence, Motion = __initMotion()