module REPLinModule

import Base: LineEdit, REPL

## This code was adapted from the following:
##    https://github.com/Keno/Gallium.jl/blob/1ef7111880495f3c5a7989d88a5fbc60e7eeb285/src/lldbrepl.jl
## Copyright (c) 2015: Keno Fischer. Licensed under the MIT "Expat" License:
##    https://github.com/Keno/Gallium.jl/blob/b4bc668a4cbd0f2d4f63fbdb0597a1264afd7b4d/LICENSE.md

active_module = Base

"""
    REPLinModule.set(mod)

Make `mod` the active module for the REPLinModule REPL mode. Activate this mode with the `}` key.
"""
function set(mod)
    global active_module = mod
    panel.prompt = make_prompt()
    return
end

make_prompt() = string("julia $active_module> ")

function run_repl(repl)
    mirepl = isdefined(repl,:mi) ? repl.mi : repl

    main_mode = mirepl.interface.modes[1]

    const keymap = Dict{Any,Any}(
        '}' => function (s,args...)
            if isempty(s)
                if !haskey(s.mode_state,panel)
                    s.mode_state[panel] = LineEdit.init_state(repl.t,panel)
                end
                LineEdit.transition(s,panel)
            else
                LineEdit.edit_insert(s,'}')
            end
        end
    )
    # Setup the repl panel
    global panel = LineEdit.Prompt(make_prompt();
        # Copy colors from the prompt object
        prompt_prefix=Base.text_colors[:green],
        prompt_suffix=main_mode.prompt_suffix,
        on_enter = Base.REPL.return_callback)

    hp = main_mode.hist
    hp.mode_mapping[:rim] = panel
    panel.hist = hp

    panel.on_done = REPL.respond(repl,panel; pass_empty = false) do line
        if !isempty(line)
            :( eval($(REPLinModule.active_module), parse($line)) )
        else
            :(  )
        end
    end

    push!(mirepl.interface.modes, panel)

    search_prompt, skeymap = LineEdit.setup_search_keymap(hp)
    mk = REPL.mode_keymap(main_mode)

    b = Dict{Any,Any}[skeymap, mk, LineEdit.history_keymap, LineEdit.default_keymap, LineEdit.escape_defaults]

    panel.keymap_dict = LineEdit.keymap(Dict{Any,Any}[skeymap, mk, main_mode.keymap_dict, LineEdit.history_keymap, LineEdit.default_keymap, LineEdit.escape_defaults])
    main_mode.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, keymap)
    nothing
end


function __init__()
    if isdefined(Base, :active_repl)
        run_repl(Base.active_repl)
    else
        atreplinit() do repl
            repl.interface = Base.REPL.setup_interface(repl)
            run_repl(repl)
        end
    end
end

end # module
