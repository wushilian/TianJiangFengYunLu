#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

from paths import GAME
GAME_DIR = GAME
SRC = GAME_DIR / "Graphics" / "Pictures" / "Endflash"
OUT = GAME_DIR / "Graphics" / "Pictures" / "TrueEnd"
OUT.mkdir(parents=True, exist_ok=True)

FONT_BOLD = "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
FONT_MED = "/usr/share/fonts/opentype/noto/NotoSansCJK-Medium.ttc"

SLIDES = [
    dict(bg="1", type="title", title="真结局", subtitle="三人同行", footer="天降风云录"),
    dict(bg="19", lines=[
        "兽神伏诛，天地重归寂静。",
        "陆孤梵抱着柳紫仪，",
        "带着赵梦雪，",
        "回到了天机阁。",
    ]),
    dict(bg="55", lines=[
        "兽神临死前发动“鬼神同归”，",
        "直取神女赵梦雪。",
        "柳紫仪挡在她身前，",
        "以圣女之血承受了全部神力。",
    ]),
    dict(bg="64", lines=[
        "代价是，柳紫仪的魂魄",
        "被神力一点点撕碎。",
        "她倒在陆孤梵怀里，轻声道：",
        "“这一次，换你带我回家。”",
    ]),
    dict(bg="73", lines=[
        "陆孤梵没有哭。",
        "他取出回魂权杖，",
        "握紧盘古神仗，",
        "运转苍龙剑诀。",
    ]),
    dict(bg="82", lines=[
        "回魂权杖召回魂魄，",
        "盘古神仗重铸经脉，",
        "苍龙剑诀以命为桥。",
        "三器合一，逆天改命。",
    ]),
    dict(bg="91", lines=[
        "金光散尽。",
        "柳紫仪睁开眼，",
        "赵梦雪也扑了上来。",
        "三个人的手，终于重新握在一起。",
    ]),
    dict(bg="127", lines=[
        "道玄退位，道伊一脉伏法。",
        "无极派与魔教止戈，",
        "柳紫仪以圣女之名废除血祭。",
        "江湖终于有了新的秩序。",
    ]),
    dict(bg="136", lines=[
        "陆孤梵没有当武林盟主，",
        "也没有当无极派掌门。",
        "他带着赵梦雪和柳紫仪，",
        "回到平安镇，开了一间小小医馆。",
    ]),
    dict(bg="28", type="end", title="全剧终", subtitle="三个人一起走", footer="天降风云录 · 真结局「三人同行」"),
]


def wrap(text, font, width):
    lines = []
    for raw in text.split("\n"):
        cur = ""
        for ch in raw:
            if font.getlength(cur + ch) <= width:
                cur += ch
            else:
                if cur:
                    lines.append(cur)
                cur = ch
        if cur:
            lines.append(cur)
    return lines


def load_bg(name):
    im = Image.open(SRC / f"{name}.png").convert("RGB")
    if im.size != (640, 480):
        im = im.resize((640, 480), Image.Resampling.LANCZOS)
    return im


def add_overlay(im):
    overlay = Image.new("RGBA", im.size, (6, 10, 18, 108))
    im = Image.alpha_composite(im.convert("RGBA"), overlay)
    # subtle vignette
    mask = Image.new("L", im.size, 0)
    md = ImageDraw.Draw(mask)
    md.rectangle((40, 40, 600, 440), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(70))
    dark = Image.new("RGBA", im.size, (0, 0, 0, 90))
    im = Image.composite(im, Image.alpha_composite(im, dark), mask)
    return im


def draw_text_panel(im, lines, footer):
    d = ImageDraw.Draw(im)
    font = ImageFont.truetype(FONT_MED, 25)
    small = ImageFont.truetype(FONT_MED, 15)
    title_font = ImageFont.truetype(FONT_BOLD, 17)

    wrapped = []
    for line in lines:
        wrapped.extend(wrap(line, font, 500))
    line_h = 35
    text_h = line_h * len(wrapped)
    top = 300 - max(0, len(wrapped) - 4) * 12
    panel = Image.new("RGBA", im.size, (0, 0, 0, 0))
    pd = ImageDraw.Draw(panel)
    pd.rounded_rectangle((52, top - 22, 588, top + text_h + 20), radius=14,
                         fill=(7, 11, 20, 190), outline=(226, 214, 188, 95), width=1)
    im = Image.alpha_composite(im, panel)
    d = ImageDraw.Draw(im)
    y = top
    for line in wrapped:
        d.text((320, y), line, font=font, anchor="ma", fill=(255, 249, 233, 255),
               stroke_width=2, stroke_fill=(0, 0, 0, 230))
        y += line_h
    d.text((24, 22), "天降风云录 · 真结局", font=title_font, fill=(236, 215, 166, 245),
           stroke_width=2, stroke_fill=(0, 0, 0, 220))
    d.text((24, 448), footer, font=small, fill=(235, 230, 215, 220),
           stroke_width=1, stroke_fill=(0, 0, 0, 220))
    d.text((616, 448), "按 C 继续", font=small, anchor="ra", fill=(235, 230, 215, 200),
           stroke_width=1, stroke_fill=(0, 0, 0, 220))
    return im


def draw_title(im, title, subtitle, footer, end=False):
    d = ImageDraw.Draw(im)
    if end:
        f1 = ImageFont.truetype(FONT_BOLD, 54)
        f2 = ImageFont.truetype(FONT_MED, 26)
        fs = ImageFont.truetype(FONT_MED, 16)
        d.text((320, 180), title, font=f1, anchor="ma", fill=(255, 246, 222, 255),
               stroke_width=3, stroke_fill=(0, 0, 0, 230))
        d.text((320, 270), subtitle, font=f2, anchor="ma", fill=(238, 204, 157, 255),
               stroke_width=2, stroke_fill=(0, 0, 0, 230))
        d.text((320, 430), footer, font=fs, anchor="ma", fill=(235, 230, 215, 220),
               stroke_width=1, stroke_fill=(0, 0, 0, 220))
    else:
        f1 = ImageFont.truetype(FONT_BOLD, 58)
        f2 = ImageFont.truetype(FONT_MED, 32)
        fs = ImageFont.truetype(FONT_MED, 20)
        d.text((320, 150), "天降风云录", font=fs, anchor="ma", fill=(236, 215, 166, 240),
               stroke_width=2, stroke_fill=(0, 0, 0, 220))
        d.text((320, 205), title, font=f1, anchor="ma", fill=(255, 246, 222, 255),
               stroke_width=3, stroke_fill=(0, 0, 0, 230))
        d.text((320, 300), subtitle, font=f2, anchor="ma", fill=(238, 204, 157, 255),
               stroke_width=2, stroke_fill=(0, 0, 0, 230))
        d.text((320, 430), footer, font=fs, anchor="ma", fill=(235, 230, 215, 220),
               stroke_width=1, stroke_fill=(0, 0, 0, 220))
    return im


def main():
    for i, slide in enumerate(SLIDES, 1):
        im = load_bg(slide["bg"])
        im = add_overlay(im)
        if slide.get("type") == "title":
            im = draw_title(im, slide["title"], slide["subtitle"], slide["footer"])
        elif slide.get("type") == "end":
            im = draw_title(im, slide["title"], slide["subtitle"], slide["footer"], end=True)
        else:
            im = draw_text_panel(im, slide["lines"], "天降风云录 · 真结局")
        out = OUT / f"{i:02d}.png"
        im.convert("RGB").save(out, "PNG", optimize=True)
        print(out)
    print("generated", len(SLIDES), "slides")


if __name__ == "__main__":
    main()
