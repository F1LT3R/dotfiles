import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window
    tab = window.current_tab

    for i, session in enumerate(tab.sessions):
        f = session.frame
        print(f"Session {i+1}: x={f.origin.x}, y={f.origin.y}, w={f.size.width}, h={f.size.height}")

iterm2.run_until_complete(main)
