# REPLinModule

This is a basic sticky REPL mode for Julia that allows you to evaluate code in a module. By default, the "active module" for this mode is `Base`. To change the active module, use `REPLinModule.set(mod)`. The active module is shown as part of the prompt.

Initiate this mode by hitting the `}` key (right curly bracket). To leave this mode, hit the backspace key at a new line. Note that the help and shell REPL modes are available, but they revert back to the normal Julia prompt after finishing. 
 


```julia
julia> using REPLinModule

julia Base> REPL
Base.REPL

julia> REPLinModule.set(Base.Meta)

julia> whos()
                          Base               Module
                          Core               Module
                          Main               Module
                  REPLinModule  18242 KB     Module
                           ans      0 bytes  Void

julia Base.Meta> whos()
                          Meta  18261 KB     Module
                        isexpr      0 bytes  Base.Meta.#isexpr
                          quot      0 bytes  Base.Meta.#quot
                    show_sexpr      0 bytes  Base.Meta.#show_sexpr

julia Base.Meta> quot(:x)
:(:x)

julia>
```

Note that this is an unregistered package. It doesn't have any tests. 

This may be superceded by a Base feature (https://github.com/JuliaLang/julia/issues/22562).
