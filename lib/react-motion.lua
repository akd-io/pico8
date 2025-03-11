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
  local function useSpring()
    assert(false, "useSpring is not implemented yet.")
  end

  local function useTransition()
    assert(false, "useTransition is not implemented yet.")
  end

  local function AnimatePresence()
    assert(false, "AnimatePresence is not implemented yet.")
  end

  local function Motion()
    assert(false, "Motion is not implemented yet.")
  end

  return useSpring, useTransition, AnimatePresence, Motion
end

local useSpring, useTransition, AnimatePresence, Motion = __initMotion()