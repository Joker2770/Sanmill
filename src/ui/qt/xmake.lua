
add_rules("mode.debug", "mode.release")

-- Set c code standard: c99, c++ code standard: c++17
set_languages("c99", "cxx17")

target("mill-pro")
    add_rules("qt.widgetapp")
    add_includedirs("$(projectdir)/.")
    add_includedirs("$(projectdir)/../../../include")
    add_includedirs("$(projectdir)/../../")
    add_includedirs("$(projectdir)/../../test")
    add_includedirs("$(projectdir)/../../perfect")
    -- add_headerfiles("$(projectdir)/*.h")
    -- add_headerfiles("$(projectdir)/../../../include/*.h")
    -- add_headerfiles("$(projectdir)/../../*.h")
    -- add_headerfiles("$(projectdir)/../../test/*.h")
    -- add_headerfiles("$(projectdir)/../../perfect/*.h")
    add_files("$(projectdir)/../../test/*.cpp")
    add_files("$(projectdir)/../../perfect/*.cpp")
    add_files("$(projectdir)/../../*.cpp")
    add_files("$(projectdir)/*.cpp")

    -- qt moc
    add_files("$(projectdir)/game.h")
    add_files("$(projectdir)/gamewindow.h")
    add_files("$(projectdir)/gameview.h")
    add_files("$(projectdir)/gamescene.h")
    add_files("$(projectdir)/database.h")
    add_files("$(projectdir)/client.h")
    add_files("$(projectdir)/movelistview.h")
    add_files("$(projectdir)/pieceitem.h")
    add_files("$(projectdir)/server.h")
    add_files("$(projectdir)/../../test/ai_shared_memory_dialog.h")
    add_files("$(projectdir)/../../thread.h")
    add_files("$(projectdir)/*.ui")
    -- add_files("$(projectdir)/*.rc")
    add_files("$(projectdir)/*.qrc")

    add_frameworks("QtCore", "QtWidgets", "QtGui", "QtMultimedia")