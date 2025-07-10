#!/usr/bin/env python3
import asyncio
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackContext, CallbackQueryHandler
import os

TOKEN = "7986904946:AAGdeQpLTROH0vrjDR2gj3HGlmc2fb5ijkw"
OWNER_ID = 1104952877

APPROVED_IPS_FILE = "/etc/xydark/bot/allowed.conf"
REQUEST_DIR = "/etc/xydark/bot/request/"

os.makedirs(REQUEST_DIR, exist_ok=True)

def get_ip(update: Update) -> str:
    return update.effective_message.text.split()[-1] if len(update.message.text.split()) > 1 else update.effective_message.text.strip()

async def start(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        await update.message.reply_text("❌ Akses ditolak.")
        return
    await update.message.reply_text("🤖 Bot aktif.
Gunakan /help untuk daftar perintah.")

async def help_command(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        return
    await update.message.reply_text("""
📌 Perintah Tersedia:
/start - Mulai bot
/ip - Lihat IP VPS
/approve <ip> <hari> - Setujui IP
/revoke <ip> - Hapus IP dari whitelist
/listip - Daftar IP yang diapprove
""")

async def ip(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        return
    stream = os.popen("curl -s ipv4.icanhazip.com")
    current_ip = stream.read().strip()
    await update.message.reply_text(f"🌐 IP VPS: `{current_ip}`", parse_mode='Markdown')

async def approve(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        return
    if len(context.args) < 1:
        await update.message.reply_text("⚠️ Format: /approve <ip> [hari]")
        return
    ip = context.args[0]
    days = context.args[1] if len(context.args) > 1 else "30"
    with open(APPROVED_IPS_FILE, "a") as f:
        f.write(f"{ip} {days}\n")
    await update.message.reply_text(f"✅ IP {ip} diapprove selama {days} hari.")

async def revoke(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        return
    if len(context.args) < 1:
        await update.message.reply_text("⚠️ Format: /revoke <ip>")
        return
    ip = context.args[0]
    if not os.path.exists(APPROVED_IPS_FILE):
        await update.message.reply_text("❌ Tidak ada data whitelist.")
        return
    with open(APPROVED_IPS_FILE, "r") as f:
        lines = f.readlines()
    with open(APPROVED_IPS_FILE, "w") as f:
        for line in lines:
            if not line.startswith(ip):
                f.write(line)
    await update.message.reply_text(f"🗑️ IP {ip} dihapus dari whitelist.")

async def listip(update: Update, context: CallbackContext):
    if update.effective_user.id != OWNER_ID:
        return
    if not os.path.exists(APPROVED_IPS_FILE):
        await update.message.reply_text("📭 Whitelist kosong.")
        return
    with open(APPROVED_IPS_FILE, "r") as f:
        data = f.read().strip()
    await update.message.reply_text(f"📜 IP Whitelist:
{data}")

async def handle_request(update: Update, context: CallbackContext):
    query = update.callback_query
    await query.answer()
    data = query.data
    ip = data.split(":")[1]
    if data.startswith("approve"):
        with open(APPROVED_IPS_FILE, "a") as f:
            f.write(f"{ip} 30\n")
        await query.edit_message_text(f"✅ IP {ip} telah diapprove oleh Owner.")
    elif data.startswith("reject"):
        await query.edit_message_text(f"❌ IP {ip} ditolak oleh Owner.")

async def main():
    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", help_command))
    app.add_handler(CommandHandler("ip", ip))
    app.add_handler(CommandHandler("approve", approve))
    app.add_handler(CommandHandler("revoke", revoke))
    app.add_handler(CommandHandler("listip", listip))
    app.add_handler(CallbackQueryHandler(handle_request))
    print("🤖 Bot Telegram aktif...")
    await app.run_polling()

if __name__ == "__main__":
    asyncio.run(main())
