#!/usr/bin/env python3
"""Re-applies caelestia-shell patches after package updates."""

import re
import sys

SHELL_QML = "/etc/xdg/quickshell/caelestia/shell.qml"
WORKSPACES_QML = "/etc/xdg/quickshell/caelestia/modules/bar/components/workspaces/Workspaces.qml"

WORKSPACES_OLD = '''            onClicked: event => {
                const ws = (layout.childAt(event.x, event.y) as Workspace)?.ws;
                if (!ws)
                    return;
                if (Hypr.activeWsId !== ws)
                    Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${ws}" })` : `workspace ${ws}`);
                else
                    Hypr.dispatch(Hypr.usingLua ? \'hl.dsp.workspace.toggle_special("special")\' : "togglespecialworkspace special");
            }'''

WORKSPACES_NEW = '''            onClicked: event => {
                const child = layout.childAt(event.x, event.y);
                const ws = child?.isWorkspace ? child.ws : null;
                if (!ws)
                    return;
                if (root.activeWsId !== ws)
                    Hypr.dispatch(`hl.dsp.focus({ workspace = "${ws}" })`);
                else
                    Hypr.dispatch(\'hl.dsp.workspace.toggle_special("special")\');
            }'''


def fix_shell_qml():
    with open(SHELL_QML, 'r') as f:
        content = f.read()

    new_content = re.sub(r'^//@ pragma DefaultEnv .*\n', '', content, flags=re.MULTILINE)
    removed = content.count('\n') - new_content.count('\n')

    if removed == 0:
        print("fix-caelestia-shell: DefaultEnv pragmas already absent, nothing to do")
    else:
        with open(SHELL_QML, 'w') as f:
            f.write(new_content)
        print(f"fix-caelestia-shell: removed {removed} DefaultEnv pragma line(s) from shell.qml")


def fix_workspaces_qml():
    with open(WORKSPACES_QML, 'r') as f:
        content = f.read()

    if WORKSPACES_NEW in content:
        print("fix-caelestia-workspace: already applied, nothing to do")
    elif WORKSPACES_OLD in content:
        with open(WORKSPACES_QML, 'w') as f:
            f.write(content.replace(WORKSPACES_OLD, WORKSPACES_NEW))
        print("fix-caelestia-workspace: applied successfully")
    else:
        print("fix-caelestia-workspace: WARNING - pattern not found, upstream may have changed Workspaces.qml")
        print("fix-caelestia-workspace: manual review needed: " + WORKSPACES_QML)


fix_shell_qml()
fix_workspaces_qml()
