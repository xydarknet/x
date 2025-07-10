import logging
import subprocess
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    filters,
)
from datetime import datetime

# ─────────────────────────────────────────────
# Konfigurasi Bot
with open("bot.conf", "r") as f:
    BOT_TOKEN = f.read().strip()

with open("owner.conf", "r") as f:
    OWNER_ID = int(f.read().strip())

with open("allowed_id", "r") as f:
    ALLOWED_IDS = [int(i.strip()) for i in f.readlines() if i.strip().isdigit()]

# Logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)

# ─────────────────────────────────────────────
# Cek akses ID
def is_allowed(user_id: int):
    return user_id == OWNER_ID or user_id in ALLOWED_IDS

# ─────────────────────────────────────────────
# Perintah start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    if not is_allowed(user_id):
        await update.message.reply_text("🚫 Akses ditolak.")
        return
    keyboard = [
        [InlineKeyboardButton("📡 SSH Menu", callback_data="menu_ssh")],
        [InlineKeyboardButton("⚡ XRAY Menu", callback_data="menu_xray")],
        [InlineKeyboardButton("⚙️ System Info", callback_data="menu_sys")],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text("🤖 Pilih menu:", reply_markup=reply_markup)

# ─────────────────────────────────────────────
# Handler tombol inline
async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    user_id = query.from_user.id
    if not is_allowed(user_id):
        await query.answer("Akses ditolak.", show_alert=True)
        return
    await query.answer()

    if query.data == "menu_ssh":
        await query.edit_message_text("📡 SSH Commands:\n/addssh\n/delssh\n/renewssh\n/ceklogssh")
    elif query.data == "menu_xray":
        await query.edit_message_text("⚡ XRAY Commands:\n/addvmess\n/addvless\n/addtrojan\n/renewtrojan")
    elif query.data == "menu_sys":
        out = subprocess.getoutput("bash /etc/xydark/system-info.sh")
        await query.edit_message_text(f"<code>{out}</code>", parse_mode="HTML")

# ─────────────────────────────────────────────
# Perintah /addssh contoh
async def addssh(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    if not is_allowed(user_id):
        await update.message.reply_text("🚫 Akses ditolak.")
        return

    await update.message.reply_text("⏳ Membuat akun SSH...")
    try:
        out = subprocess.getoutput("bash /etc/xray/addssh")
        await update.message.reply_text(f"<code>{out}</code>", parse_mode="HTML")
    except Exception as e:
        await update.message.reply_text(f"❌ Error: {e}")

# ─────────────────────────────────────────────
# Handler command tak dikenal
async def unknown(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("❓ Perintah tidak dikenali.")

# ─────────────────────────────────────────────
# Main
if __name__ == "__main__":
    app = ApplicationBuilder().token(BOT_TOKEN).build()

    # Handler
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("addssh", addssh))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, unknown))
    app.add_handler(MessageHandler(filters.COMMAND, unknown))
    app.add_handler(MessageHandler(filters.ALL, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.NEW_CHAT_MEMBERS, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.LEFT_CHAT_MEMBER, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.NEW_CHAT_TITLE, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.PINNED_MESSAGE, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.NEW_CHAT_PHOTO, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.DELETE_CHAT_PHOTO, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.GROUP_CHAT_CREATED, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.SUPERGROUP_CHAT_CREATED, unknown))
    app.add_handler(MessageHandler(filters.StatusUpdate.CHANNEL_CHAT_CREATED, unknown))

    from telegram.ext import CallbackQueryHandler
    app.add_handler(CallbackQueryHandler(button_handler))

    print("🤖 Bot is running...")
    app.run_polling()
