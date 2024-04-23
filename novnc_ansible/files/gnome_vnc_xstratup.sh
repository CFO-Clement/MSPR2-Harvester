#!/bin/sh

# Nettoie tout processus VNC précédemment lancé
vncserver -kill $DISPLAY

# Définit les ressources X et le fond d'écran
xrdb $HOME/.Xresources
xsetroot -solid grey

# Démarre GNOME
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Assurez-vous que le gestionnaire de session GNOME est correctement lancé
if [ -x /usr/bin/gnome-session ]; then
    exec gnome-session
elif [ -x /usr/bin/startxfce4 ]; then
    exec startxfce4
elif [ -x /usr/bin/startlxde ]; then
    exec startlxde
else
    exec xterm  # Si rien d'autre n'est disponible, lance un xterm
fi
