document.addEventListener("click", (event) => {
    const closeNotificationMoreMenus = () => {
        document.querySelectorAll(".notification-more-menu.is-open").forEach((menu) => {
            menu.classList.remove("is-open");
        });

        document.querySelectorAll(".notification-more-btn.is-open").forEach((button) => {
            button.classList.remove("is-open");
        });
    };

    const moreButton = event.target.closest("[data-notification-more]");

    if (moreButton) {
        event.stopPropagation();

        const item = moreButton.closest(".notification-menu-item");
        const menu = item?.querySelector(".notification-more-menu");

        document.querySelectorAll(".notification-more-menu.is-open").forEach((openMenu) => {
            if (openMenu !== menu) {
                openMenu.classList.remove("is-open");
            }
        });

        document.querySelectorAll(".notification-more-btn.is-open").forEach((openButton) => {
            if (openButton !== moreButton) {
                openButton.classList.remove("is-open");
            }
        });

        menu?.classList.toggle("is-open");
        moreButton.classList.toggle("is-open");
        return;
    }

    const markSeenButton = event.target.closest("[data-mark-seen]");

    if (markSeenButton) {
        event.stopPropagation();

        const item = markSeenButton.closest(".notification-menu-item");
        const dropdown = markSeenButton.closest(".notification-menu");
        const activeFilter = dropdown?.querySelector("[data-notification-filter].active")?.dataset.notificationFilter;

        item?.classList.remove("is-unseen");
        item?.classList.add("is-seen");
        item?.querySelector(".notification-more-menu")?.classList.remove("is-open");
        item?.querySelector(".notification-more-btn")?.classList.remove("is-open");

        if ((activeFilter === "unseen" || activeFilter === "unread") && item) {
            item.hidden = true;
        }

        return;
    }

    const filterButton = event.target.closest("[data-notification-filter]");

    if (!filterButton) {
        const chatFilterButton = event.target.closest("[data-chat-filter]");

        if (!chatFilterButton) {
            const conversationTrigger = event.target.closest("[data-open-conversation], .message-thread");

            if (conversationTrigger) {
                event.preventDefault();
                event.stopPropagation();

                const templatePanel = document.querySelector("#conversationPopover");

                if (!templatePanel) {
                    return;
                }

                const name = conversationTrigger.dataset.chatName
                    || conversationTrigger.querySelector("strong")?.textContent?.trim()
                    || "Messages";
                const avatar = conversationTrigger.dataset.chatAvatar
                    || name.trim().charAt(0).toUpperCase()
                    || "M";
                const preview = conversationTrigger.dataset.chatPreview
                    || conversationTrigger.querySelector("small")?.textContent?.trim()
                    || "New message is waiting.";

                const panel = templatePanel.cloneNode(true);
                const openPanels = document.querySelectorAll("[data-conversation-panel]");

                panel.removeAttribute("id");
                panel.dataset.conversationPanel = "true";
                panel.hidden = false;
                panel.style.setProperty("--conversation-right", `${24 + openPanels.length * 356}px`);
                panel.hidden = false;
                panel.classList.remove("is-minimized");
                panel.querySelector("[data-conversation-name]").textContent = name;
                panel.querySelector("[data-conversation-avatar]").textContent = avatar;
                panel.querySelector("[data-conversation-preview]").textContent = preview;
                document.body.appendChild(panel);

                const dropdownElement = conversationTrigger.closest(".dropdown-menu");
                const dropdownToggle = dropdownElement?.previousElementSibling;
                const dropdown = dropdownToggle ? bootstrap.Dropdown.getInstance(dropdownToggle) : null;

                dropdown?.hide();
                closeNotificationMoreMenus();
                return;
            }

            const closeConversationButton = event.target.closest("[data-conversation-close]");

            if (closeConversationButton) {
                event.preventDefault();
                const panel = closeConversationButton.closest(".conversation-popover");
                panel?.remove();

                document.querySelectorAll("[data-conversation-panel]").forEach((openPanel, index) => {
                    openPanel.style.setProperty("--conversation-right", `${24 + index * 356}px`);
                });

                return;
            }

            const minimizeConversationButton = event.target.closest("[data-conversation-minimize]");

            if (minimizeConversationButton) {
                event.preventDefault();
                minimizeConversationButton.closest(".conversation-popover")?.classList.toggle("is-minimized");
                return;
            }

            closeNotificationMoreMenus();
            return;
        }

        event.stopPropagation();

        const chatDropdown = chatFilterButton.closest(".chat-header-menu");

        if (!chatDropdown) {
            return;
        }

        const filter = chatFilterButton.dataset.chatFilter;
        const filterButtons = chatDropdown.querySelectorAll("[data-chat-filter]");
        const chatItems = chatDropdown.querySelectorAll(".chat-header-item");

        filterButtons.forEach((button) => {
            button.classList.toggle("active", button === chatFilterButton);
        });

        chatItems.forEach((item) => {
            item.hidden = filter === "unseen" && !item.classList.contains("is-unseen");
        });

        return;
    }

    event.stopPropagation();
    closeNotificationMoreMenus();

    const dropdown = filterButton.closest(".notification-menu");

    if (!dropdown) {
        return;
    }

    const filter = filterButton.dataset.notificationFilter;
    const filterButtons = dropdown.querySelectorAll("[data-notification-filter]");
    const notificationItems = dropdown.querySelectorAll(".notification-menu-item");

    filterButtons.forEach((button) => {
        button.classList.toggle("active", button === filterButton);
    });

    notificationItems.forEach((item) => {
        item.hidden = (filter === "unseen" || filter === "unread") && !item.classList.contains("is-unseen");
    });
});
