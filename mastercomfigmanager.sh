#!/bin/sh

while true; do
    printf "\nEnter '(d)ownload' to download/update files, '(r)emove' to remove files or '(Q)uit' to quit:\n"
    read -r ACTION
    ACTION=$(echo "$ACTION" | tr '[:upper:]' '[:lower:]')

    if [ "$ACTION" = "download" ] || [ "$ACTION" = "d" ]; then
        printf "Getting latest release of mastercomfig\n"
        LATEST_RELEASE=$(curl -s https://api.github.com/repos/mastercomfig/mastercomfig/releases/latest)
        LATEST_RELEASE_NUMBER=$(printf "$LATEST_RELEASE" | grep -E ".*tag_name.*" | cut -d '"' -f 4)
        printf "Latest release is $LATEST_RELEASE_NUMBER\n"

        LIST=$(printf "$LATEST_RELEASE" | grep ".*vpk" | cut -d : -f 2,3 | tr -d \")

        FILE_LIST=$(printf "$LIST" | sed -n 'p;n' | tr -d ',' | tr -d ' ')
        FILE_COUNT=$(printf "$FILE_LIST" | wc -l)
        FILE_COUNT=$((FILE_COUNT + 1))
        URL_LIST=$(printf "$LIST" | sed -n 'n;p')

        printf "$FILE_LIST" | sed '=' | sed 'N; s/\n/. /'
        printf "\nEnter the number(s) corresponding to the file(s) you want to download seperated by commas:\n"
        read -r FILE_NUMBER

        for ELEMENT in $(printf "$FILE_NUMBER" | tr ',' ' '); do
            if [ "$ELEMENT" -ge 1 ] && [ "$ELEMENT" -le "$FILE_COUNT" ]; then
                URL=$(printf "$URL_LIST" | sed -n ${ELEMENT}p )
                NAME=$(printf "$FILE_LIST" | sed -n ${ELEMENT}p )

                if wget -q -O $NAME $URL; then
                    printf "Download completed for $NAME.\n"
                else
                    printf "Download failed for $NAME.\n"
                    continue
                fi
            else
                printf "$ELEMENT is an invalid input, continuing.\n"
                continue
            fi
        done

    elif [ "$ACTION" = "remove" ] || [ "$ACTION" = "r" ] ; then
        FILE_LIST=$(ls -1 mastercomfig*.vpk 2>/dev/null)
        FILE_COUNT=$(printf "$FILE_LIST" | wc -l)
        FILE_COUNT=$((FILE_COUNT + 1))

        if [ -z "$FILE_LIST" ]; then
            printf "No files found for removal.\n"
            continue
        fi

        printf "\nFetching downloaded files:\n"
        printf "$FILE_LIST" | sed '=' | sed 'N; s/\n/. /'

        printf "\nEnter the number(s) corresponding to the file(s) you want to remove seperated by commas:\n"
        read -r FILE_NUMBER

        for ELEMENT in $(printf "$FILE_NUMBER" | tr ',' ' '); do
            if [ "$ELEMENT" -ge 1 ] && [ "$ELEMENT" -le "$FILE_COUNT" ]; then
                NAME=$(printf "$FILE_LIST" | sed -n ${ELEMENT}p )

                if [ -f "$NAME" ]; then
                    rm "$NAME"
                    printf "File $NAME removed.\n"
                else
                    printf "File $NAME does not exist.\n"
                    continue
                fi
            else
                printf "$ELEMENT is an invalid input, continuing.\n"
                continue
            fi
        done


    else
        [ "$ACTION" = "quit" ] || [ "$ACTION" = "q" ] || [ -z "$ACTION" ] && break
        printf "Invalid action. Please enter 'download', 'remove' or 'quit'.\n"
    fi

done
