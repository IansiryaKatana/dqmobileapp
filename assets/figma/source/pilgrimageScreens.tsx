import { useState } from "react";
import {
  ArrowLeft, FileCheck, Shirt, Building2, Star, Leaf,
  Smartphone, CreditCard, Wifi, Navigation, ChevronRight, Bookmark,
} from "lucide-react";
import { BookOpen } from "lucide-react";
import { ImageWithFallback } from "@/app/components/figma/ImageWithFallback";
import logisticsVisa from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.43_PM.jpeg";
import logisticsIhram from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.16_PM.jpeg";
import logisticsHaram from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.16_PM__1_.jpeg";
import logisticsNabawi from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.16_PM__2_.jpeg";
import logisticsJannat from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.17_PM.jpeg";
import logisticsNusuk from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.17_PM__1_.jpeg";
import logisticsMoney from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.17_PM__2_.jpeg";
import logisticsMobile from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.17_PM__3_.jpeg";
import logisticsTrain from "@/imports/WhatsApp_Image_2026-07-08_at_1.17.17_PM__4_.jpeg";
import { Screen } from "./types";
import { navy, yellow, cream, sand, white, charcoal, muted, border } from "./context";
import { StatusBar, BackBtn, GeoPattern } from "./shared";

// ─── PILGRIMAGE ICON SYSTEM ───────────────────────────────────────────────────

// Kaaba — clean side-profile view, used in banner + small contexts
export function KaabaIcon({ size = 48 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 56 56" fill="none">
      {/* Faint tawaf halo */}
      <circle cx="28" cy="30" r="25" stroke={yellow} strokeWidth="0.8" strokeDasharray="3 5" opacity="0.18" />
      {/* Kaaba body */}
      <rect x="12" y="10" width="32" height="36" rx="2" fill={navy} stroke={yellow} strokeWidth="2.2" />
      {/* Kiswa belt */}
      <rect x="12" y="20" width="32" height="7" fill={yellow} opacity="0.08" stroke={yellow} strokeWidth="1.6" />
      {/* Calligraphy lines inside belt */}
      <line x1="16" y1="23.5" x2="26" y2="23.5" stroke={yellow} strokeWidth="1.1" opacity="0.6" />
      <line x1="28" y1="23.5" x2="40" y2="23.5" stroke={yellow} strokeWidth="1.1" opacity="0.6" />
      {/* Arched door of the Kaaba */}
      <path d="M21 46 L21 36 Q28 28 35 36 L35 46 Z" fill={yellow} />
      <line x1="28" y1="32" x2="28" y2="46" stroke={navy} strokeWidth="1.5" opacity="0.35" />
      {/* Hajar al-Aswad (Black Stone) corner */}
      <circle cx="12" cy="46" r="3.2" fill={yellow} opacity="0.42" />
    </svg>
  );
}

// Aerial Kaaba — top-down Tawaf view, for hero + Umrah featured card
export function KaabaAerialIcon({ size = 72 }: { size?: number }) {
  const cx = 28, cy = 28;
  const dots = [0, 40, 80, 120, 160, 200, 240, 280, 320];
  return (
    <svg width={size} height={size} viewBox="0 0 56 56" fill="none">
      {/* Outer glow */}
      <circle cx={cx} cy={cy} r="27" fill={yellow} opacity="0.04" />
      {/* Outer tawaf path */}
      <circle cx={cx} cy={cy} r="23" fill="none" stroke={yellow} strokeWidth="1" strokeDasharray="4 4" opacity="0.22" />
      {/* Inner marble courtyard */}
      <circle cx={cx} cy={cy} r="15.5" fill={yellow} opacity="0.05" stroke={yellow} strokeWidth="0.8" />
      {/* Kaaba square (top view) */}
      <rect x="15" y="15" width="26" height="26" rx="2" fill={navy} stroke={yellow} strokeWidth="2.5" />
      {/* Kiswa cross-lines on top face */}
      <line x1="15" y1="22" x2="41" y2="22" stroke={yellow} strokeWidth="1.3" opacity="0.5" />
      <line x1="15" y1="34" x2="41" y2="34" stroke={yellow} strokeWidth="1.3" opacity="0.5" />
      <line x1="22" y1="15" x2="22" y2="41" stroke={yellow} strokeWidth="1.3" opacity="0.25" />
      <line x1="34" y1="15" x2="34" y2="41" stroke={yellow} strokeWidth="1.3" opacity="0.25" />
      {/* Hajar al-Aswad corner */}
      <circle cx="15" cy="41" r="3.5" fill={yellow} opacity="0.52" />
      {/* Pilgrim dots circling */}
      {dots.map((deg) => {
        const r = (deg * Math.PI) / 180;
        return <circle key={deg} cx={cx + 15.5 * Math.cos(r)} cy={cy + 15.5 * Math.sin(r)} r="2" fill={yellow} opacity="0.65" />;
      })}
    </svg>
  );
}

// TawafIcon — circular tawaf ring + Kaaba centre (Umrah)
export function TawafIcon({ size = 64 }: { size?: number }) {
  const cx = 32, cy = 32;
  const pilgrims = [0, 52, 104, 156, 208, 260, 312];
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      {/* Outer tawaf ring */}
      <circle cx={cx} cy={cy} r="27" fill="none" stroke={yellow} strokeWidth="3" />
      {/* Pilgrim dots circling */}
      {pilgrims.map((deg) => {
        const r = (deg * Math.PI) / 180;
        return (
          <circle key={deg} cx={cx + 19 * Math.cos(r)} cy={cy + 19 * Math.sin(r)}
            r="2.5" fill={yellow} opacity="0.55" />
        );
      })}
      {/* Kaaba body */}
      <rect x="20" y="19" width="24" height="28" rx="2" fill={navy} stroke={yellow} strokeWidth="2.5" />
      {/* Kiswa belt */}
      <rect x="20" y="28" width="24" height="5" fill={yellow} opacity="0.12" stroke={yellow} strokeWidth="1.5" />
      {/* Golden door */}
      <path d="M26 47 L26 38 Q32 32 38 38 L38 47 Z" fill={yellow} />
      <line x1="32" y1="35" x2="32" y2="47" stroke={navy} strokeWidth="1.5" opacity="0.3" />
      {/* Hajar al-Aswad */}
      <circle cx="20" cy="47" r="2.5" fill={yellow} opacity="0.45" />
    </svg>
  );
}

// Arafat mountain — for Hajj featured card
export function ArafatIcon({ size = 72 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 56 56" fill="none">
      {/* Sun disc */}
      <circle cx="28" cy="13" r="8" fill={yellow} opacity="0.15" />
      <circle cx="28" cy="13" r="5" fill={yellow} opacity="0.28" />
      {[0, 45, 90, 135, 180, 225, 270, 315].map((d) => {
        const r = (d * Math.PI) / 180;
        return <line key={d} x1={28 + 7 * Math.cos(r)} y1={13 + 7 * Math.sin(r)} x2={28 + 11 * Math.cos(r)} y2={13 + 11 * Math.sin(r)} stroke={yellow} strokeWidth="1.3" strokeLinecap="round" opacity="0.45" />;
      })}
      {/* Mountain silhouette */}
      <path d="M2 46 L14 26 L20 34 L28 18 L36 34 L43 24 L54 46 Z" fill={navy} stroke={yellow} strokeWidth="1.8" strokeLinejoin="round" />
      {/* Peak glow */}
      <path d="M28 18 L33 28 L23 28 Z" fill={yellow} opacity="0.2" />
      {/* Ground strip */}
      <rect x="2" y="46" width="52" height="3" rx="1.5" fill={navy} stroke={yellow} strokeWidth="1" opacity="0.35" />
      {/* Pilgrim silhouettes at base */}
      {[9, 18, 28, 38, 47].map((x) => (
        <g key={x}>
          <circle cx={x} cy="44" r="1.6" fill={yellow} opacity="0.7" />
          <line x1={x} y1="45.5" x2={x} y2="49" stroke={yellow} strokeWidth="1.1" strokeLinecap="round" opacity="0.5" />
        </g>
      ))}
    </svg>
  );
}

// Spiritual Preparation — open dua palms with light
export function DuaHandsIcon({ size = 40 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" fill="none">
      {/* Light rays */}
      <line x1="20" y1="4" x2="20" y2="1" stroke={yellow} strokeWidth="2" strokeLinecap="round" />
      <line x1="14" y1="6" x2="12" y2="3" stroke={yellow} strokeWidth="1.6" strokeLinecap="round" opacity="0.7" />
      <line x1="26" y1="6" x2="28" y2="3" stroke={yellow} strokeWidth="1.6" strokeLinecap="round" opacity="0.7" />
      <line x1="10" y1="10" x2="8" y2="8" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" opacity="0.4" />
      <line x1="30" y1="10" x2="32" y2="8" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" opacity="0.4" />
      {/* Left open palm */}
      <path d="M4 28 Q4 19 8 17 Q10.5 16 12.5 18 Q14 14 15.5 17 L15.5 34 Q10 36 6 34 Q4 32 4 29Z" fill={navy} stroke={yellow} strokeWidth="1.6" strokeLinejoin="round" />
      <line x1="10" y1="16" x2="10" y2="19" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" />
      <line x1="14" y1="14" x2="14" y2="17" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" />
      {/* Right open palm (mirror) */}
      <path d="M36 28 Q36 19 32 17 Q29.5 16 27.5 18 Q26 14 24.5 17 L24.5 34 Q30 36 34 34 Q36 32 36 29Z" fill={navy} stroke={yellow} strokeWidth="1.6" strokeLinejoin="round" />
      <line x1="30" y1="16" x2="30" y2="19" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" />
      <line x1="26" y1="14" x2="26" y2="17" stroke={yellow} strokeWidth="1.3" strokeLinecap="round" />
    </svg>
  );
}

// Visiting Madinah — Prophet's Mosque dome + minarets
export function MadinahDomeIcon({ size = 40 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" fill="none">
      {/* Left minaret */}
      <rect x="1" y="16" width="6" height="21" rx="1" fill={navy} stroke={yellow} strokeWidth="1.3" />
      <path d="M1 16 L4 8 L7 16Z" fill={yellow} />
      <circle cx="4" cy="7" r="1.6" fill={yellow} />
      {/* Right minaret */}
      <rect x="33" y="16" width="6" height="21" rx="1" fill={navy} stroke={yellow} strokeWidth="1.3" />
      <path d="M33 16 L36 8 L39 16Z" fill={yellow} />
      <circle cx="36" cy="7" r="1.6" fill={yellow} />
      {/* Main building body */}
      <rect x="9" y="24" width="22" height="13" rx="1" fill={navy} stroke={yellow} strokeWidth="1.3" />
      {/* Famous green dome (rendered in gold for brand) */}
      <path d="M9 24 Q20 9 31 24Z" fill={navy} stroke={yellow} strokeWidth="1.8" />
      {/* Crescent + star on dome apex */}
      <path d="M18 15 Q20 12 22 15 Q20 13.5 18 15Z" fill={yellow} />
      <circle cx="23" cy="12" r="1.3" fill={yellow} />
      {/* Arched door */}
      <path d="M16 37 L16 29 Q20 25 24 29 L24 37Z" fill={yellow} opacity="0.85" />
      {/* Windows */}
      <rect x="10" y="26" width="4" height="5" rx="1" fill={yellow} opacity="0.38" />
      <rect x="26" y="26" width="4" height="5" rx="1" fill={yellow} opacity="0.38" />
    </svg>
  );
}

// Logistics — pilgrim suitcase with crescent
export function LogisticsIcon({ size = 40 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" fill="none">
      {/* Handle arc */}
      <path d="M14 16 L14 11 Q14 8 17 8 L23 8 Q26 8 26 11 L26 16" stroke={yellow} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
      {/* Case body */}
      <rect x="6" y="16" width="28" height="20" rx="3" fill={navy} stroke={yellow} strokeWidth="1.6" />
      {/* Horizontal zip seam */}
      <line x1="6" y1="26" x2="34" y2="26" stroke={yellow} strokeWidth="0.9" opacity="0.4" />
      {/* Lock */}
      <rect x="16" y="22" width="8" height="6" rx="2" fill={yellow} opacity="0.9" />
      <path d="M18 22 L18 20 Q20 18 22 20 L22 22" stroke={yellow} strokeWidth="1.4" strokeLinecap="round" fill="none" />
      {/* Crescent moon badge */}
      <path d="M26 18.5 Q30 21.5 26 24.5 Q24 23 26 18.5Z" fill={yellow} opacity="0.38" />
      {/* Wheels */}
      <circle cx="13" cy="37" r="2.8" fill={yellow} opacity="0.6" />
      <circle cx="27" cy="37" r="2.8" fill={yellow} opacity="0.6" />
    </svg>
  );
}

// FAQ — speech bubble with question mark
export function FAQBubbleIcon({ size = 40 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40" fill="none">
      {/* Bubble */}
      <path d="M5 5 Q5 3 7 3 L33 3 Q35 3 35 5 L35 26 Q35 28 33 28 L23 28 L17 35 L17 28 L7 28 Q5 28 5 26 Z" fill={navy} stroke={yellow} strokeWidth="1.6" />
      {/* Question mark arc */}
      <path d="M16 17 Q16 11 20 11 Q24 11 24 15 Q24 18 20 19.5 L20 22" stroke={yellow} strokeWidth="2.4" strokeLinecap="round" />
      {/* Dot */}
      <circle cx="20" cy="25" r="2" fill={yellow} />
    </svg>
  );
}

// ─── FAQ SCREEN ───────────────────────────────────────────────────────────────
export function FAQScreen({ goBack }: { goBack: () => void }) {
  const [openIdx, setOpenIdx] = useState<number | null>(null);

  const faqs = [
    {
      q: "How long does it take to perform Umrah?",
      a: "Umrah can take anywhere from 2 to 4 hours to complete, including Tawaf, Sa'i, and having the head shaved or hair cut. Some pilgrims spend longer for prayer and reflection at the Kaaba.",
    },
    {
      q: "What time of day is the quietest time to perform Umrah?",
      a: "The quietest times are generally between Fajr and sunrise, or late at night after Isha. Avoiding peak times such as weekends and major Islamic dates is also advisable.",
    },
    {
      q: "Can I put my Ihram on once I get to Makkah?",
      a: "No. You must enter the state of Ihram before crossing the Meeqat — the designated boundary around Makkah. Passing the Meeqat without Ihram when intending Umrah or Hajj is not permissible.",
    },
    {
      q: "Can I use my phone or camera during Umrah?",
      a: "Yes, phones and cameras are generally allowed in Masjid al-Haram. Be respectful of others during worship and avoid photographing fellow pilgrims without consent. Some inner areas may restrict photography.",
    },
    {
      q: "Can I visit Madinah first?",
      a: "Yes, visiting Madinah before Makkah is permissible. You would assume Ihram at Madinah's Meeqat (Dhul Hulayfah) when departing for Makkah to perform Umrah.",
    },
    {
      q: "Can I use handsoap after using the toilet?",
      a: "Yes. Unscented soap is permissible while in Ihram. Avoid any scented products including scented soaps, shampoos and deodorants, as these are prohibited in the state of Ihram.",
    },
    {
      q: "Can a menstruating woman perform Umrah?",
      a: "A woman in her menstrual cycle may enter Ihram and perform all Umrah rituals except Tawaf and Sa'i. She should wait until her period ends, perform ghusl, then complete these remaining rituals.",
    },
    {
      q: "What is forbidden in the state of Ihram?",
      a: "Prohibited acts include: cutting hair or nails, using perfume or scented products, sexual relations, hunting animals, covering the head (for men), and wearing stitched clothing (for men).",
    },
    {
      q: "Do I need a visa for Umrah?",
      a: "Yes. Most nationalities require an Umrah visa to enter Saudi Arabia for pilgrimage. This is typically arranged through a licensed Umrah travel agent or operator in your country.",
    },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />

      {/* Header */}
      <div className="flex items-center gap-3 px-5 py-2.5">
        <BackBtn onBack={goBack} />
        <div className="flex-1">
          <h1 className="font-bold text-[17px]" style={{ color: charcoal }}>FAQ</h1>
          <p className="text-[11px]" style={{ color: muted }}>Common Questions &amp; Answers</p>
        </div>
        <span
          className="text-[11px] font-bold px-3 py-1 rounded-full"
          style={{ background: sand, color: muted, border: `1px solid ${border}` }}
        >
          {faqs.length} questions
        </span>
      </div>

      {/* Intro banner */}
      <div className="mx-5 mb-4 px-4 py-3 rounded-[16px] flex items-center gap-3"
           style={{ background: "rgba(255,196,0,0.1)", border: "1px solid rgba(255,196,0,0.2)" }}>
        <KaabaIcon size={32} />
        <p className="text-[13px] leading-snug" style={{ color: charcoal }}>
          Frequently asked questions about <span className="font-bold">Umrah &amp; Hajj</span>
        </p>
      </div>

      {/* Accordion list */}
      <div className="flex-1 overflow-y-auto px-5 pb-8 space-y-2">
        {faqs.map((f, i) => {
          const isOpen = openIdx === i;
          return (
            <div
              key={i}
              className="rounded-[16px] overflow-hidden transition-all"
              style={{ border: `1.5px solid ${isOpen ? yellow : border}` }}
            >
              <button
                onClick={() => setOpenIdx(isOpen ? null : i)}
                className="w-full flex items-center justify-between px-4 py-4 text-left"
                style={{ background: isOpen ? navy : white }}
              >
                <p
                  className="flex-1 text-[14px] font-medium pr-3 leading-snug"
                  style={{ color: isOpen ? white : charcoal }}
                >
                  {f.q}
                </p>
                <div
                  className="w-7 h-7 rounded-full flex items-center justify-center shrink-0 transition-transform duration-200"
                  style={{
                    background: isOpen ? yellow : sand,
                    transform: isOpen ? "rotate(180deg)" : "rotate(0deg)",
                  }}
                >
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                    <path d="M2 4L6 8L10 4" stroke={isOpen ? navy : muted} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </div>
              </button>
              {isOpen && (
                <div
                  className="px-4 pb-4 pt-3"
                  style={{ background: white, borderTop: `1px solid ${border}` }}
                >
                  <p className="text-[13px] leading-relaxed" style={{ color: muted }}>{f.a}</p>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─── HAJJ GUIDE SCREEN ───────────────────────────────────────────────────────
export function HajjGuideScreen({ goBack }: { goBack: () => void }) {
  const [openStep, setOpenStep] = useState<number | null>(0);

  const steps = [
    {
      n: 1,
      title: "Before Assuming Ihram",
      arabic: "الإحرام",
      img: "https://images.unsplash.com/photo-1650446647974-451d05d2136d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Ghusl · Niyyah · Settle your affairs",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>You are a guest of Allah (swt) for Hajj — the fifth pillar of Islam. Prepare yourself in the best possible way. Perform Ghusl, clip your nails and remove excess body hair before leaving home.</p>
          <div className="space-y-2 pt-1">
            {["Make sincere intention (niyyah) to perform Hajj solely for Allah's pleasure","Settle all debts and resolve any outstanding disputes","Seek forgiveness from those you may have wronged","Write a will before traveling","Learn the rites of Hajj before departing"].map((t, i) => (
              <div key={i} className="flex gap-2.5 items-start">
                <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: yellow }} />
                <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 2,
      title: "Change into Your Ihram",
      arabic: "لباس الإحرام",
      img: "https://images.unsplash.com/photo-1668304521248-0dd0cc00fbfc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Men: two white cloths · Women: modest dress",
      body: (
        <div className="space-y-3 text-sm">
          <div className="rounded-2xl p-3 space-y-1.5" style={{ background: sand }}>
            <p className="font-bold text-xs" style={{ color: navy }}>Men</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Two white unstitched sheets — izar (lower) and rida (upper). No head coverings, no stitched garments. Slippers must not cover the ankle.</p>
          </div>
          <div className="rounded-2xl p-3 space-y-1.5" style={{ background: sand }}>
            <p className="font-bold text-xs" style={{ color: navy }}>Women</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Usual modest clothing. Must not wear gloves or cover the face (except in front of non-Mahram men if they normally wear niqab).</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Change before crossing the Miqat. If flying, change before departure or during a stopover.</p>
        </div>
      ),
    },
    {
      n: 3,
      title: "Make Intention & Recite Talbiyah",
      arabic: "النية والتلبية",
      img: "https://images.unsplash.com/photo-1594937113195-27f8b9046013?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "At the Miqat · Recite loudly until Day of Eid",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>At the Miqat, make your intention for the type of Hajj you are performing (most common: Hajj al-Tamattu), then recite the Talbiyah:</p>
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="text-sm leading-relaxed text-right mb-3" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ</p>
            <p className="text-xs text-white mb-1">Labbayka Allahumma labbayka…</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>At your service, Allah — all praise, favour and sovereignty are Yours.</p>
          </div>
          <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">📖</span>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Continue reciting Talbiyah frequently until you stone Jamarat al-Aqabah on the 10th of Dhul Hijjah. (Sahih Muslim 1184)</p>
          </div>
        </div>
      ),
    },
    {
      n: 4,
      title: "8th Dhul Hijjah — Arrive in Mina",
      arabic: "يوم التروية — منى",
      img: "https://images.unsplash.com/photo-1677835214504-9648944c3e50?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Spend the night in Mina · 5 prayers",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>On the 8th of Dhul Hijjah (Yawm al-Tarwiyah), make your way to Mina and spend the day and night there.</p>
          <div className="space-y-2">
            {[{ icon: "🕌", text: "Pray Dhuhr, Asr, Maghrib, Isha and Fajr in Mina — shortening prayers to 2 rak'ahs (Qasr)" },{ icon: "🌙", text: "Spend the night in your tent. Reflect, make du'a, and prepare your heart for the Day of Arafat." }].map(({ icon, text }) => (
              <div key={text} className="flex gap-2.5 items-start rounded-xl px-3 py-2.5" style={{ background: sand }}>
                <span className="text-sm flex-shrink-0">{icon}</span>
                <p className="text-xs leading-relaxed" style={{ color: charcoal }}>{text}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 5,
      title: "9th Dhul Hijjah — Stand at Arafat",
      arabic: "يوم عرفة",
      img: "https://images.unsplash.com/photo-1604655983671-9d03650f604c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "The pinnacle of Hajj · Du'a from Dhuhr to sunset",
      body: (
        <div className="space-y-3 text-sm">
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.85)" }}>"Hajj is Arafat." (Abu Dawud 1949)</p>
            <p className="text-xs mt-1.5 font-semibold" style={{ color: yellow }}>— The Prophet Muhammad ﷺ</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Stand at Arafat from after Dhuhr until sunset. This is the most important act of Hajj — make abundant du'a, dhikr, and seek Allah's forgiveness.</p>
          <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">🤲</span>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>The best du'a is: <span className="font-semibold" style={{ color: charcoal }}>Lā ilāha illallāhu wahdahu lā sharīka lah, lahul-mulku wa lahul-hamdu wa huwa 'alā kulli shay'in qadīr.</span></p>
          </div>
        </div>
      ),
    },
    {
      n: 6,
      title: "Night in Muzdalifah",
      arabic: "المزدلفة",
      img: "https://images.unsplash.com/photo-1513072064285-240f87fa81e8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Collect pebbles · Pray Maghrib & Isha",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>After sunset on the 9th, depart Arafat for Muzdalifah. Combine and shorten Maghrib (3) and Isha (2) prayers upon arrival.</p>
          <div className="space-y-2">
            {[{ icon: "🪨", text: "Collect 49 or 70 small pebbles (the size of a chickpea) for the stoning of Jamarat." },{ icon: "😴", text: "Spend the night under the open sky at Muzdalifah — this is Sunnah." },{ icon: "🌅", text: "Pray Fajr here. Depart for Mina after Fajr (or in the last portion of the night for the elderly/weak)." }].map(({ icon, text }) => (
              <div key={text} className="flex gap-2.5 items-start rounded-xl px-3 py-2.5" style={{ background: sand }}>
                <span className="text-sm flex-shrink-0">{icon}</span>
                <p className="text-xs leading-relaxed" style={{ color: charcoal }}>{text}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 7,
      title: "10th Dhul Hijjah — Rami al-Jamarat",
      arabic: "رمي الجمرات",
      img: "https://images.unsplash.com/photo-1780265861345-a787b955b505?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Stone Jamarat al-Aqabah · 7 pebbles",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Return to Mina and stone Jamarat al-Aqabah (the large pillar) with 7 pebbles. Say <span className="font-semibold" style={{ color: charcoal }}>Bismillah, Allahu Akbar</span> with each throw.</p>
          <div className="rounded-2xl p-4 text-center" style={{ background: navy }}>
            <p className="text-base mb-2" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>بِسْمِ اللهِ اللهُ أَكْبَرُ</p>
            <p className="text-xs text-white">Recite with each of the 7 pebbles</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>After stoning, the Talbiyah stops. Next: sacrifice, shave/cut hair, and change out of Ihram.</p>
        </div>
      ),
    },
    {
      n: 8,
      title: "Sacrifice & Exit Ihram",
      arabic: "الهدي والتحلل",
      img: "https://images.unsplash.com/photo-1656635098050-cd59fc6a2a52?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Qurbani · Shave or cut hair · Change clothes",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>On the Day of Eid (10th Dhul Hijjah), after stoning Jamarat al-Aqabah:</p>
          {[{ n: "1", title: "Sacrifice (Hady)", desc: "Offer your sacrificial animal (or arrange through an authorised agent)." },{ n: "2", title: "Shave or cut hair (Halq/Taqsir)", desc: "Men should ideally shave the head completely. Women cut a fingertip's length from their hair." },{ n: "3", title: "Change out of Ihram", desc: "After shaving, you may change into regular clothing. Most restrictions of Ihram are now lifted." }].map(({ n, title, desc }) => (
            <div key={n} className="flex gap-3">
              <div className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-extrabold flex-shrink-0" style={{ background: navy, color: yellow }}>{n}</div>
              <div>
                <p className="text-xs font-bold" style={{ color: charcoal }}>{title}</p>
                <p className="text-xs mt-0.5 leading-relaxed" style={{ color: muted }}>{desc}</p>
              </div>
            </div>
          ))}
        </div>
      ),
    },
    {
      n: 9,
      title: "Tawaf al-Ifadah & Sa'i",
      arabic: "طواف الإفاضة والسعي",
      img: "https://images.unsplash.com/photo-1736240624842-c13db7ba4275?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "7 circuits of the Kaaba · 7 rounds of Sa'i",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Return to Makkah and perform Tawaf al-Ifadah — 7 circuits around the Kaaba. This is a pillar of Hajj; without it, Hajj is incomplete.</p>
          <div className="rounded-2xl p-3" style={{ background: sand }}>
            <p className="font-bold text-xs mb-1.5" style={{ color: navy }}>After Tawaf</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Pray 2 rak'ahs behind Maqam Ibrahim, drink Zamzam water, then perform Sa'i — walking 7 times between Safa and Marwah.</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>After completing Sa'i, all restrictions of Ihram are fully lifted — Hajj is essentially complete.</p>
        </div>
      ),
    },
    {
      n: 10,
      title: "Days of Tashreeq & Farewell Tawaf",
      arabic: "أيام التشريق وطواف الوداع",
      img: "https://images.unsplash.com/photo-1720482229376-d5574ffeb0c8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "11th–13th: stone all 3 Jamarat · Tawaf al-Wida",
      body: (
        <div className="space-y-3 text-sm">
          <div className="rounded-2xl p-3" style={{ background: sand }}>
            <p className="font-bold text-xs mb-1.5" style={{ color: navy }}>Days of Tashreeq (11th–13th Dhul Hijjah)</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Stone all three Jamarat (small, medium, large) — 7 pebbles each — after midday on each day. You may depart on the 12th if you leave before sunset (Rukhsah).</p>
          </div>
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="font-bold text-xs text-white mb-1.5">Tawaf al-Wida (Farewell Tawaf)</p>
            <p className="text-xs leading-relaxed" style={{ color: "rgba(255,255,255,0.7)" }}>The last act before leaving Makkah. Perform 7 circuits around the Kaaba. Make du'a and bid farewell to the Sacred Mosque with a heavy heart and tears of gratitude.</p>
          </div>
          <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">🤲</span>
            <p className="text-xs italic leading-relaxed" style={{ color: muted }}>May Allah accept your Hajj and make it a Hajj Mabrur — a pilgrimage accepted by Allah.</p>
          </div>
        </div>
      ),
    },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      {/* Header */}
      <div className="relative overflow-hidden px-5 pt-12 pb-5" style={{ background: navy }}>
        <div className="absolute -top-8 -right-8 w-36 h-36 rounded-full opacity-10" style={{ background: yellow }} />
        <div className="absolute bottom-0 left-12 w-16 h-16 rounded-full opacity-5" style={{ background: white, transform: "translateY(50%)" }} />
        <button onClick={goBack} className="relative w-8 h-8 flex items-center justify-center rounded-full mb-4" style={{ background: "rgba(255,255,255,0.12)" }}>
          <ArrowLeft size={16} color="white" />
        </button>
        <p className="relative text-xs font-bold uppercase tracking-widest mb-1" style={{ color: yellow }}>Umrah & Hajj</p>
        <h1 className="relative text-xl font-extrabold text-white leading-tight">Hajj Guide</h1>
        <p className="relative text-xs mt-1.5" style={{ color: "rgba(255,255,255,0.5)" }}>10 steps · pillars, rituals, du'as & locations</p>
        <div className="relative flex gap-1.5 mt-4 flex-wrap">
          {steps.map((s) => (
            <button
              key={s.n}
              onClick={() => setOpenStep(openStep === s.n - 1 ? null : s.n - 1)}
              className="w-7 h-7 rounded-full text-xs font-bold flex items-center justify-center transition-all"
              style={{
                background: openStep === s.n - 1 ? yellow : "rgba(255,255,255,0.15)",
                color: openStep === s.n - 1 ? navy : "rgba(255,255,255,0.7)",
              }}
            >
              {s.n}
            </button>
          ))}
        </div>
      </div>

      {/* Steps */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {steps.map((step, i) => {
          const isOpen = openStep === i;
          return (
            <div
              key={step.n}
              className="rounded-2xl overflow-hidden transition-all"
              style={{
                background: white,
                border: `1px solid ${isOpen ? navy : border}`,
                boxShadow: isOpen ? "0 4px 16px rgba(11,20,29,0.12)" : "0 1px 4px rgba(11,20,29,0.05)",
              }}
            >
              <button
                className="w-full flex items-center gap-3 px-4 py-3.5 text-left"
                onClick={() => setOpenStep(isOpen ? null : i)}
              >
                <div
                  className="w-10 h-10 rounded-2xl flex flex-col items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <span className="text-[9px] font-semibold uppercase" style={{ color: isOpen ? yellow : muted }}>Step</span>
                  <span className="text-sm font-extrabold leading-none" style={{ color: isOpen ? yellow : navy }}>{step.n}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-sm leading-tight" style={{ color: charcoal }}>{step.title}</p>
                  <p className="text-xs mt-0.5 truncate" style={{ color: muted }}>{step.summary}</p>
                </div>
                <div
                  className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <svg width="10" height="6" viewBox="0 0 10 6" fill="none" style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
                    <path d="M1 1L5 5L9 1" stroke={isOpen ? white : navy} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </div>
              </button>
              {isOpen && (
                <div style={{ borderTop: `1px solid ${border}` }}>
                  <div style={{ height: 180, background: sand, overflow: "hidden" }}>
                    <ImageWithFallback src={step.img} alt={step.title} className="w-full h-full object-cover object-top" />
                  </div>
                  <div className="px-4 pt-3 pb-1 flex items-center gap-2">
                    <div className="w-1 h-4 rounded-full" style={{ background: yellow }} />
                    <p className="text-sm" style={{ color: navy, fontFamily: "'Amiri Quran', serif" }}>{step.arabic}</p>
                  </div>
                  <div className="px-4 pb-4">{step.body}</div>
                </div>
              )}
            </div>
          );
        })}

        <div className="rounded-3xl px-5 py-5 flex gap-4 items-start" style={{ background: navy }}>
          <span className="text-2xl">🕋</span>
          <div>
            <p className="font-bold text-white text-sm">Hajj Mabrur</p>
            <p className="text-xs mt-1.5 leading-relaxed" style={{ color: "rgba(255,255,255,0.6)" }}>
              The Prophet ﷺ said: "The reward for an accepted Hajj is nothing less than Paradise." (Bukhari & Muslim)
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── SPIRITUAL PREPARATION SCREEN ───────────────────────────────────────────
export function SpiritualPrepScreen({ goBack }: { goBack: () => void }) {
  const [openStep, setOpenStep] = useState<number | null>(0);

  const steps = [
    {
      n: 1,
      title: "Journey of the Hearts",
      arabic: "رحلة القلوب",
      img: "https://images.unsplash.com/photo-1564769625905-50e93615e769?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Taqwa · Clear intentions · Amends · Dua list",
      body: (
        <div className="space-y-2">
          {[
            "Prepare the best provision: Taqwa (consciousness of Allah)",
            "Set clear intentions: Sincerely for Allah",
            "Strengthen your connection with Allah: Increase your acts of worship",
            "Sabr: Patience & flexibility",
            "Keep focused: Food, friends, scheduling",
            "Make amends: With family, friends",
            "Visualise the journey: Mentally walk through steps",
            "Shukr: Busy your heart & tongue with Allah's remembrance",
            "Prepare to leave: Clear your debts, make your will and close off all activities",
            "Dua list: Ask from your heart for everything you desire",
          ].map((t, i) => (
            <div key={i} className="flex gap-2.5 items-start">
              <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: yellow }} />
              <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
            </div>
          ))}
        </div>
      ),
    },
    {
      n: 2,
      title: "Du'a",
      arabic: "الدعاء",
      img: "https://images.unsplash.com/photo-1593178974994-8dbd7e11f0fe?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Essence of worship · Accepted at blessed sites",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>
            One of the most virtuous deeds to perform at Umrah is to make du'a. Du'a performed during Umrah is accepted by Allah, particularly when it is made at blessed sites including the Mataf (where Tawaf is performed), the Hajr-e-Aswad (the black stone), the Maqam-e-Ibrahim, and between Safa and Marwah during Sa'i.
          </p>
          <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
            <p className="text-xs font-bold mb-1" style={{ color: navy }}>Du'a is the essence of worship.</p>
          </div>
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="font-bold text-xs text-white mb-2">Hadith | Tirmidhi</p>
            <p className="text-xs leading-relaxed" style={{ color: "rgba(255,255,255,0.8)" }}>
              Allah Almighty loves when we turn to Him to share our deepest thoughts and seek His favours and He is constantly attentive to our prayers and supplications.
            </p>
          </div>
          <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
            <p className="text-xs leading-relaxed italic" style={{ color: charcoal }}>
              "And when my servants ask you about Me, then tell them I am near. I answer the call of every believer when they call upon me so let them also answer my call and believe in me so they may find rightful guidance."
            </p>
          </div>
        </div>
      ),
    },
    {
      n: 3,
      title: "Daily Routine — Suggested",
      arabic: "الروتين اليومي",
      img: "https://images.unsplash.com/photo-1466810297867-9f9cf563ae0f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Enhance your connection with Allah inshaAllah",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>
            This recommended daily routine is designed to enhance your connection with Allah inshaAllah.
          </p>
          <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
            <p className="font-bold text-xs mb-1.5" style={{ color: navy }}>Last third of the night</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>
              Tahajjud: Wake up in the last third of the night and perform Tahajjud (voluntary night prayer). This is a special time to seek Allah's mercy and forgiveness. The Tahajjud Adhan will usually be given 1 hour before Fajr Salah. The Prophet Muhammad ﷺ said: "Our Lord, Blessed and Exalted, descends every night to the lowest heaven during the last third of the night and says: 'Who is calling upon Me, so that I may answer him? Who is asking of Me, so that I may give to him? Who is seeking My forgiveness, so that I may forgive him?'" (Bukhari no. 1145)
            </p>
          </div>
          <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
            <p className="font-bold text-xs mb-1.5" style={{ color: navy }}>Morning in the Haram</p>
            <div className="space-y-1.5">
              {[
                "Fajr Prayer: If you have not gone for Tahajjud Salah already, then head to the Haram early to perform Fajr in congregation. Spend time in Dhikr (remembrance of Allah) while waiting for prayer.",
                "Morning Dhikr: Engage in morning adhkar after Fajr. Remain in the Masjid and recite Quran until sunrise.",
              ].map((t, i) => (
                <div key={i} className="flex gap-2 items-start">
                  <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: yellow }} />
                  <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      ),
    },
    {
      n: 4,
      title: "30 Virtues of Dhikr — Remembering God",
      arabic: "فضائل الذكر",
      img: "https://images.unsplash.com/photo-1584286595398-a59511e0649d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "From Ibn al-Qayyim · Wabil as-Sayyib",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>
            It has been summarised from the book 'Invocation of God' by Ibn al-Qayyim [Wabil as-Sayyib in Arabic].
          </p>
          <div className="space-y-1.5">
            {[
              "Remembrance of God [Dhikr] drives away and breaks the devil [shaytan]",
              "It pleases ar-Rahman [the Most-Merciful]",
              "It removes the cares and worries of the Heart",
              "It brings joy and happiness to the Heart",
              "It strengthens both body and Heart",
              "It endows the person with Love of God, which is the very spirit of Islam — for God has opened a way of access to everything, and the way to Love is constancy in Remembrance [Dhikr]",
              "It endows one with Muraqabah (watchful awareness of Allah)",
            ].map((t, i) => (
              <div key={i} className="flex gap-2.5 items-start">
                <span className="text-xs font-bold flex-shrink-0 mt-0.5" style={{ color: yellow }}>{i + 1}.</span>
                <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 5,
      title: "The Universe — The Source of Ma'rifah",
      arabic: "مصدر المعرفة",
      img: "https://images.unsplash.com/photo-1462331940025-496dfbfc7564?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Three fundamental questions · Three tools",
      body: (
        <div className="space-y-3 text-sm">
          <p className="text-xs leading-relaxed" style={{ color: muted }}>
            Historically, humans have forever grappled with three fundamental ontological questions.
          </p>
          <div className="space-y-2">
            {[
              { q: "1", text: "Who made me and everything around me? What is the nature of this Creator?" },
              { q: "2", text: "What is the purpose of my life? What am I doing here and why have I been created?" },
              { q: "3", text: "What will happen to me when I die?" },
            ].map(({ q, text }) => (
              <div key={q} className="flex gap-3 rounded-xl px-3 py-2.5" style={{ background: sand }}>
                <div className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0" style={{ background: navy, color: yellow }}>{q}</div>
                <p className="text-xs leading-relaxed" style={{ color: charcoal }}>{text}</p>
              </div>
            ))}
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>
            Islam teaches us that there are three tools that Allah has bestowed upon us to help us discover Him, learn about Him and love Him. They are:
          </p>
          <div className="space-y-1.5">
            {[
              "Natural Disposition (Fitrah)",
              "Intellect / Rational thinking (Aql)",
              "Divine Revelation (Wahy) — the Quran and Sunnah",
            ].map((t, i) => (
              <div key={i} className="flex gap-2.5 items-start">
                <span className="text-xs font-bold flex-shrink-0 mt-0.5" style={{ color: yellow }}>{i + 1}.</span>
                <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 6,
      title: "Crying for Allah",
      arabic: "البكاء لله",
      img: "https://images.unsplash.com/photo-1504052434569-70ad5836ab65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Weeping out of fear & love · Softening the heart",
      body: (
        <div className="space-y-3 text-sm">
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="text-xs italic leading-relaxed" style={{ color: "rgba(255,255,255,0.9)" }}>
              "And they fall down on their faces weeping" [17:109]
            </p>
          </div>
          <div className="space-y-2">
            <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
              <p className="text-xs font-bold mb-1" style={{ color: navy }}>1. Abu Hurayrah (ra) narrated:</p>
              <p className="text-xs leading-relaxed italic" style={{ color: muted }}>
                The Messenger of Allah ﷺ said: "A man who weeps for fear of Allah will not enter Hell until the milk goes back into the udder, and dust produced (when fighting) for the sake of Allah and the smoke of Hell will never coexist." Narrated by Tirmidhi and Nasaa'i.
              </p>
            </div>
            <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
              <p className="text-xs font-bold mb-1" style={{ color: navy }}>2. The Messenger of Allah ﷺ said:</p>
              <p className="text-xs leading-relaxed italic" style={{ color: muted }}>
                "There are seven whom Allah will shade with His shade on the day when there will be no shade but His: a just ruler; a young man who grows up worshipping Allah; a man whose heart is attached to the mosque; two people who love one another for the sake of Allah…"
              </p>
            </div>
          </div>
        </div>
      ),
    },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      {/* Header */}
      <div className="relative overflow-hidden px-5 pt-12 pb-5" style={{ background: navy }}>
        <div className="absolute -top-8 -right-8 w-36 h-36 rounded-full opacity-10" style={{ background: yellow }} />
        <div className="absolute bottom-0 left-12 w-16 h-16 rounded-full opacity-5" style={{ background: white, transform: "translateY(50%)" }} />
        <button onClick={goBack} className="relative w-8 h-8 flex items-center justify-center rounded-full mb-4" style={{ background: "rgba(255,255,255,0.12)" }}>
          <ArrowLeft size={16} color="white" />
        </button>
        <p className="relative text-xs font-bold uppercase tracking-widest mb-1" style={{ color: yellow }}>Umrah & Hajj</p>
        <h1 className="relative text-xl font-extrabold text-white leading-tight">Spiritual Preparation</h1>
        <p className="relative text-xs mt-1.5" style={{ color: "rgba(255,255,255,0.5)" }}>6 topics · intention, dhikr, du'a & heart</p>
        <div className="relative flex gap-1.5 mt-4 flex-wrap">
          {steps.map((s) => (
            <button
              key={s.n}
              onClick={() => setOpenStep(openStep === s.n - 1 ? null : s.n - 1)}
              className="w-7 h-7 rounded-full text-xs font-bold flex items-center justify-center transition-all"
              style={{
                background: openStep === s.n - 1 ? yellow : "rgba(255,255,255,0.15)",
                color: openStep === s.n - 1 ? navy : "rgba(255,255,255,0.7)",
              }}
            >
              {s.n}
            </button>
          ))}
        </div>
      </div>

      {/* Steps */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {steps.map((step, i) => {
          const isOpen = openStep === i;
          return (
            <div
              key={step.n}
              className="rounded-2xl overflow-hidden transition-all"
              style={{
                background: white,
                border: `1px solid ${isOpen ? navy : border}`,
                boxShadow: isOpen ? "0 4px 16px rgba(11,20,29,0.12)" : "0 1px 4px rgba(11,20,29,0.05)",
              }}
            >
              <button
                className="w-full flex items-center gap-3 px-4 py-3.5 text-left"
                onClick={() => setOpenStep(isOpen ? null : i)}
              >
                <div
                  className="w-10 h-10 rounded-2xl flex flex-col items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <span className="text-[9px] font-semibold uppercase" style={{ color: isOpen ? yellow : muted }}>Step</span>
                  <span className="text-sm font-extrabold leading-none" style={{ color: isOpen ? yellow : navy }}>{step.n}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-sm leading-tight" style={{ color: charcoal }}>{step.title}</p>
                  <p className="text-xs mt-0.5 truncate" style={{ color: muted }}>{step.summary}</p>
                </div>
                <div
                  className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <svg width="10" height="6" viewBox="0 0 10 6" fill="none" style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
                    <path d="M1 1L5 5L9 1" stroke={isOpen ? white : navy} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </div>
              </button>
              {isOpen && (
                <div style={{ borderTop: `1px solid ${border}` }}>
                  <div style={{ height: 180, background: sand, overflow: "hidden" }}>
                    <ImageWithFallback src={step.img} alt={step.title} className="w-full h-full object-cover object-center" />
                  </div>
                  <div className="px-4 pt-3 pb-1 flex items-center gap-2">
                    <div className="w-1 h-4 rounded-full" style={{ background: yellow }} />
                    <p className="text-sm" style={{ color: navy, fontFamily: "'Amiri Quran', serif" }}>{step.arabic}</p>
                  </div>
                  <div className="px-4 pb-4">{step.body}</div>
                </div>
              )}
            </div>
          );
        })}

        <div className="rounded-3xl px-5 py-5 flex gap-4 items-start" style={{ background: navy }}>
          <span className="text-2xl">🤲</span>
          <div>
            <p className="font-bold text-white text-sm">May Allah Accept Your Journey</p>
            <p className="text-xs mt-1.5 leading-relaxed" style={{ color: "rgba(255,255,255,0.6)" }}>
              "And when My servants ask you concerning Me — indeed I am near. I respond to the invocation of the supplicant when he calls upon Me." (Quran 2:186)
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── UMRAH GUIDE SCREEN ──────────────────────────────────────────────────────
export function UmrahGuideScreen({ goBack }: { goBack: () => void }) {
  const [openStep, setOpenStep] = useState<number | null>(0);

  const steps = [
    {
      n: 1,
      title: "Before Assuming Ihram",
      arabic: "الإحرام",
      img: "https://images.unsplash.com/photo-1668304521248-0dd0cc00fbfc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Ghusl · Niyyah · Settle your affairs",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="leading-relaxed">You are a guest of Allah (swt) — prepare yourself in the best possible way. It is highly recommended (Sunnah) to perform Ghusl before wearing Ihram. Clip your nails and remove excess body hair before leaving home.</p>
          <div className="space-y-2 pt-1">
            {["Make sincere intention (niyyah) to perform Umrah solely for Allah's pleasure", "Settle all debts and resolve any outstanding disputes", "Seek forgiveness from those you may have wronged", "Write a will before traveling"].map((t, i) => (
              <div key={i} className="flex gap-2.5 items-start">
                <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: yellow }} />
                <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
              </div>
            ))}
          </div>
        </div>
      ),
    },
    {
      n: 2,
      title: "Change into Your Ihram",
      arabic: "لباس الإحرام",
      img: "https://images.unsplash.com/photo-1605553378313-22d0dc541393?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Men: two white cloths · Women: modest dress",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <div className="rounded-2xl p-3 space-y-1.5" style={{ background: sand }}>
            <p className="font-bold text-xs" style={{ color: navy }}>Men</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Wear two white unstitched sheets — one wrapped around the waist (izar) and one draped over the upper body (rida). Slippers should not cover the ankle. No head coverings permitted.</p>
          </div>
          <div className="rounded-2xl p-3 space-y-1.5" style={{ background: sand }}>
            <p className="font-bold text-xs" style={{ color: navy }}>Women</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>May wear usual modest clothing. Must avoid wearing gloves or covering the face (except in front of non-Mahram men if they normally wear niqab).</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Ensure you change into Ihram attire <span className="font-semibold" style={{ color: charcoal }}>before crossing the Miqat</span>. If flying, change before departure or during a stopover if applicable.</p>
        </div>
      ),
    },
    {
      n: 3,
      title: "Make the Intention at Miqat",
      arabic: "النية عند الميقات",
      img: "https://images.unsplash.com/photo-1594937113195-27f8b9046013?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Miqat is 20–30 min before landing",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="leading-relaxed text-xs" style={{ color: muted }}>For those flying from abroad, the Miqat point is usually passed 20–30 minutes before landing. The airline may announce this — or track it yourself. At this point, make the intention for Umrah:</p>
          <div className="rounded-2xl p-4 text-center" style={{ background: navy }}>
            <p className="text-base leading-relaxed mb-2" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>لَبَّيْكَ اللَّهُمَّ عُمْرَةً</p>
            <p className="text-xs font-medium mb-1 text-white">Labbayka Allahumma 'Umratan</p>
            <p className="text-xs" style={{ color: "rgba(255,255,255,0.6)" }}>Here I am O Allah, performing Umrah</p>
          </div>
        </div>
      ),
    },
    {
      n: 4,
      title: "Recite the Talbiyah",
      arabic: "التلبية",
      img: "https://images.unsplash.com/photo-1720549973451-018d3623b55a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Recite frequently until you begin Tawaf",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Men recite loudly; women recite softly. Continue reciting until you begin Tawaf.</p>
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="text-sm leading-relaxed text-right mb-3" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ</p>
            <p className="text-xs text-white mb-2">Labbayka Allahumma labbayka, labbayka la sharika laka labbayka, innal-hamda wan-ni'mata laka wal-mulk, la sharika lak.</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>At your service, Allah, at your service. You have no partner — all praise, favour and sovereignty are Yours.</p>
          </div>
          <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">📖</span>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>The Prophet ﷺ said: "When any pilgrim utters Talbiyah, all stones, trees, and the earth to his right and left join him." (Sahih Muslim 1184)</p>
          </div>
        </div>
      ),
    },
    {
      n: 5,
      title: "Entering Masjid Al-Haram",
      arabic: "دخول المسجد الحرام",
      img: "https://images.unsplash.com/photo-1720482229376-d5574ffeb0c8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Enter with right foot · Recite du'a",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Enter the Masjid Al-Haram (the Sacred Mosque) with your <span className="font-semibold" style={{ color: charcoal }}>right foot first</span> and recite:</p>
          <div className="rounded-2xl p-4 text-center" style={{ background: navy }}>
            <p className="text-sm leading-relaxed mb-2 text-right" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ</p>
            <p className="text-xs text-white mb-1">Allahumma salli 'ala Muhammadin wa sallim. Allahumma iftah-lee abwaba rahmatika.</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>O Allah, send peace upon Muhammad. O Allah, open the doors of Your Mercy for me.</p>
          </div>
          <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">🤲</span>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Avoid distractions from devices and the busy crowds. Focus on your Lord and the significance of your journey.</p>
          </div>
        </div>
      ),
    },
    {
      n: 6,
      title: "Preparing for Tawaf",
      arabic: "التهيؤ للطواف",
      img: "https://images.unsplash.com/photo-1736240624842-c13db7ba4275?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "State of Wudu · Men: Idtiba",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="leading-relaxed text-xs" style={{ color: muted }}>Make sure you are in a state of Wudu and walk towards the Mataf area (where people circle the Ka'bah).</p>
          <div className="rounded-2xl p-3" style={{ background: sand }}>
            <p className="font-bold text-xs mb-1.5" style={{ color: navy }}>For Men — Idtiba</p>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Uncover your right shoulder by placing the upper sheet (Rida) under your right armpit and over your left shoulder. This is done <span className="font-semibold" style={{ color: charcoal }}>only during Tawaf</span>.</p>
          </div>
        </div>
      ),
    },
    {
      n: 7,
      title: "Start Tawaf",
      arabic: "بدء الطواف",
      img: "https://images.unsplash.com/photo-1780265861345-a787b955b505?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Start at Black Stone · Bismillah Allahu Akbar",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Start at Al-Hajr Al-Aswad (the Black Stone). You will see the green-fluorescent light to your right — that is your starting point.</p>
          <div className="rounded-2xl p-4 text-center" style={{ background: navy }}>
            <p className="text-base mb-2" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>بِسْمِ اللهِ اللهُ أَكْبَرُ</p>
            <p className="text-xs text-white mb-1">Bismillah Allahu Akbar</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>In the name of Allah, Allah is the Greatest</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Try touching or kissing the Black Stone — if you cannot, make a sign with your right hand towards it. Complete <span className="font-semibold" style={{ color: charcoal }}>7 circuits</span> anticlockwise around the Ka'bah. Men should walk briskly (Raml) in the first three circuits. Make any du'a, recite Dhikr or Qur'an as you walk.</p>
        </div>
      ),
    },
    {
      n: 8,
      title: "Pray Behind Maqam Ibrahim",
      arabic: "الصلاة خلف المقام",
      img: "https://images.unsplash.com/photo-1574246604907-db69e30ddb97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "2 Rak'ahs · Surah Al-Kafirun & Al-Ikhlas",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>After completing Tawaf, proceed to the Maqam Ibrahim and recite (men should cover both shoulders at this point):</p>
          <div className="rounded-2xl p-4 text-center" style={{ background: navy }}>
            <p className="text-base mb-2 text-right" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى</p>
            <p className="text-xs text-white mb-1">Wattakhidhoo min Maqaami Ibraheema musalla.</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>And take the Maqam Ibrahim as a place of Salah.</p>
          </div>
          <div className="rounded-xl px-3 py-2.5" style={{ background: sand }}>
            <p className="text-xs leading-relaxed" style={{ color: muted }}>Pray <span className="font-semibold" style={{ color: charcoal }}>2 Rak'ahs</span> behind Maqam Ibrahim if possible, otherwise as close as possible. Recite <span className="font-semibold" style={{ color: charcoal }}>Surah Al-Kafirun</span> in the first and <span className="font-semibold" style={{ color: charcoal }}>Surah Al-Ikhlas</span> in the second Rak'ah.</p>
          </div>
        </div>
      ),
    },
    {
      n: 9,
      title: "Drink Zamzam Water",
      arabic: "شرب ماء زمزم",
      img: "https://images.unsplash.com/photo-1592326871020-04f58c1a52f3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "Make du'a whilst drinking · Pour over head",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Go to the Zamzam taps and drink from it — pour some of the blessed water over your head. Make plenty of supplication for good when drinking Zamzam.</p>
          <div className="rounded-xl p-3 flex gap-2.5" style={{ background: sand }}>
            <span className="text-sm flex-shrink-0">💧</span>
            <p className="text-xs italic leading-relaxed" style={{ color: muted }}>The Prophet ﷺ said: "It [Zamzam] is blessed, it is nourishment that satisfies and a cure for sickness." (Sahih Muslim)</p>
          </div>
        </div>
      ),
    },
    {
      n: 10,
      title: "Make Your Way to Mount Safa",
      arabic: "السعي بين الصفا والمروة",
      img: "https://images.unsplash.com/photo-1513072064285-240f87fa81e8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800&q=80",
      summary: "7 times between Safa & Marwa",
      body: (
        <div className="space-y-3 text-sm" style={{ color: charcoal }}>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Make your way to Mount Safa. As you ascend towards it, recite:</p>
          <div className="rounded-2xl p-4" style={{ background: navy }}>
            <p className="text-sm leading-relaxed text-right mb-2" style={{ color: yellow, fontFamily: "'Amiri Quran', serif" }}>إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ — نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ</p>
            <p className="text-xs text-white mb-1">Innas-Safa wal-Marwata min sha'a'irillah… Nabda'u bima bada' Allahu bihi.</p>
            <p className="text-xs italic" style={{ color: "rgba(255,255,255,0.6)" }}>Verily Safa and Marwah are from the signs of Allah — I begin with what Allah begins with.</p>
          </div>
          <p className="text-xs leading-relaxed" style={{ color: muted }}>Walk <span className="font-semibold" style={{ color: charcoal }}>7 times</span> between Safa and Marwah (Safa → Marwah = 1). Men jog briskly between the two green markers. Make du'a throughout this blessed act.</p>
        </div>
      ),
    },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      {/* Header */}
      <div className="relative overflow-hidden px-5 pt-12 pb-5" style={{ background: navy }}>
        <div className="absolute -top-8 -right-8 w-36 h-36 rounded-full opacity-10" style={{ background: yellow }} />
        <div className="absolute bottom-0 left-12 w-16 h-16 rounded-full opacity-5" style={{ background: white, transform: "translateY(50%)" }} />
        <button onClick={goBack} className="relative w-8 h-8 flex items-center justify-center rounded-full mb-4" style={{ background: "rgba(255,255,255,0.12)" }}>
          <ArrowLeft size={16} color="white" />
        </button>
        <p className="relative text-xs font-bold uppercase tracking-widest mb-1" style={{ color: yellow }}>Umrah & Hajj</p>
        <h1 className="relative text-xl font-extrabold text-white leading-tight">Umrah Guide</h1>
        <p className="relative text-xs mt-1.5" style={{ color: "rgba(255,255,255,0.5)" }}>10 steps · rituals, du'as & essential tips</p>

        {/* Step progress pills */}
        <div className="relative flex gap-1.5 mt-4 flex-wrap">
          {steps.map((s) => (
            <button
              key={s.n}
              onClick={() => setOpenStep(openStep === s.n - 1 ? null : s.n - 1)}
              className="w-7 h-7 rounded-full text-xs font-bold flex items-center justify-center transition-all"
              style={{
                background: openStep === s.n - 1 ? yellow : "rgba(255,255,255,0.15)",
                color: openStep === s.n - 1 ? navy : "rgba(255,255,255,0.7)",
              }}
            >
              {s.n}
            </button>
          ))}
        </div>
      </div>

      {/* Steps */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {steps.map((step, i) => {
          const isOpen = openStep === i;
          return (
            <div
              key={step.n}
              className="rounded-2xl overflow-hidden transition-all"
              style={{
                background: white,
                border: `1px solid ${isOpen ? navy : border}`,
                boxShadow: isOpen ? "0 4px 16px rgba(11,20,29,0.12)" : "0 1px 4px rgba(11,20,29,0.05)",
              }}
            >
              <button
                className="w-full flex items-center gap-3 px-4 py-3.5 text-left"
                onClick={() => setOpenStep(isOpen ? null : i)}
              >
                {/* Step number badge */}
                <div
                  className="w-10 h-10 rounded-2xl flex flex-col items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <span className="text-[9px] font-semibold uppercase" style={{ color: isOpen ? yellow : muted }}>Step</span>
                  <span className="text-sm font-extrabold leading-none" style={{ color: isOpen ? yellow : navy }}>{step.n}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-sm leading-tight" style={{ color: charcoal }}>{step.title}</p>
                  <p className="text-xs mt-0.5 truncate" style={{ color: muted }}>{step.summary}</p>
                </div>
                <div
                  className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ background: isOpen ? navy : sand }}
                >
                  <svg width="10" height="6" viewBox="0 0 10 6" fill="none" style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
                    <path d="M1 1L5 5L9 1" stroke={isOpen ? white : navy} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </div>
              </button>

              {isOpen && (
                <div style={{ borderTop: `1px solid ${border}` }}>
                  {/* Reference image */}
                  <div style={{ height: 180, background: sand, overflow: "hidden" }}>
                    <ImageWithFallback
                      src={step.img}
                      alt={step.title}
                      className="w-full h-full object-cover object-top"
                    />
                  </div>
                  {/* Arabic name tag */}
                  <div className="px-4 pt-3 pb-1 flex items-center gap-2">
                    <div className="w-1 h-4 rounded-full" style={{ background: yellow }} />
                    <p className="text-sm" style={{ color: navy, fontFamily: "'Amiri Quran', serif" }}>{step.arabic}</p>
                  </div>
                  {/* Body */}
                  <div className="px-4 pb-4">
                    {step.body}
                  </div>
                </div>
              )}
            </div>
          );
        })}

        {/* Completion card */}
        <div className="rounded-3xl px-5 py-5 flex gap-4 items-start" style={{ background: navy }}>
          <span className="text-2xl">🕋</span>
          <div>
            <p className="font-bold text-white text-sm">Taqabbal Allahu minna wa minkum</p>
            <p className="text-xs mt-1.5 leading-relaxed" style={{ color: "rgba(255,255,255,0.6)" }}>
              May Allah accept your Umrah and make it a means of drawing closer to Him.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── LOGISTICS SCREEN ────────────────────────────────────────────────────────
export function LogisticsScreen({ goBack }: { goBack: () => void }) {
  const [open, setOpen] = useState<number | null>(null);

  const groups = [
    {
      label: "Before You Travel",
      accent: navy,
      accentBg: sand,
      items: [
        {
          title: "Umrah Visa",
          icon: <FileCheck size={20} color={navy} />,
          snippet: "e-Visa SAR 535 · Visa on arrival SAR 480",
          body: (
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-2">
                <div className="rounded-2xl p-3" style={{ background: sand }}>
                  <p className="text-xs font-bold mb-2" style={{ color: navy }}>e-Visa</p>
                  <p className="text-xs" style={{ color: charcoal }}>SAR 535 <span style={{ color: muted }}>(~£114)</span></p>
                  <p className="text-xs mt-1" style={{ color: muted }}>Application & insurance included</p>
                </div>
                <div className="rounded-2xl p-3" style={{ background: sand }}>
                  <p className="text-xs font-bold mb-2" style={{ color: navy }}>On Arrival</p>
                  <p className="text-xs" style={{ color: charcoal }}>SAR 480 <span style={{ color: muted }}>(~£102)</span></p>
                  <p className="text-xs mt-1" style={{ color: muted }}>+ SAR 180 medical (~£38)</p>
                </div>
              </div>
            </div>
          ),
        },
        {
          title: "Ihram — What to Know",
          icon: <Shirt size={20} color={navy} />,
          snippet: "Ghusl · Niyyah · Two unstitched cloths",
          body: (
            <div className="space-y-2.5">
              {[
                { n: "1", title: "Ghusl & Prayer", desc: "Perform ghusl (bath) and 2 rakat nafl salah before entering Ihram." },
                { n: "2", title: "Enter before Meeqat", desc: "Ihram must be entered before the meeqat boundary. On a flight, the airline will announce the crossing point." },
                { n: "3", title: "Wear the Garments", desc: "Two white unstitched cloths — izar (lower) and rida (upper). Slippers must leave the middle bone uncovered." },
              ].map(({ n, title, desc }) => (
                <div key={n} className="flex gap-3">
                  <div className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-extrabold flex-shrink-0" style={{ background: navy, color: yellow }}>{n}</div>
                  <div>
                    <p className="text-xs font-bold" style={{ color: charcoal }}>{title}</p>
                    <p className="text-xs mt-0.5 leading-relaxed" style={{ color: muted }}>{desc}</p>
                  </div>
                </div>
              ))}
            </div>
          ),
        },
      ],
    },
    {
      label: "Holy Sites",
      accent: navy,
      accentBg: sand,
      items: [
        {
          title: "Masjid al-Haram, Makkah",
          icon: <Building2 size={20} color={navy} />,
          snippet: "Grand Mosque tips · Arrive 30 min early",
          body: (
            <div className="space-y-2">
              {[
                { icon: "🏨", text: "Take a hotel card so you can find your way back." },
                { icon: "🚪", text: "Identify the closest door to the Haram from your hotel." },
                { icon: "⏰", text: "Arrive at least 30 min before salaah time to find a spot." },
                { icon: "🕌", text: "For Jumu'ah, arrive no later than 10am in off-peak seasons." },
              ].map(({ icon, text }) => (
                <div key={text} className="flex gap-2.5 items-start rounded-xl px-3 py-2.5" style={{ background: sand }}>
                  <span className="text-sm flex-shrink-0">{icon}</span>
                  <p className="text-xs leading-relaxed" style={{ color: charcoal }}>{text}</p>
                </div>
              ))}
            </div>
          ),
        },
        {
          title: "Masjid an-Nabawi, Madinah",
          icon: <Star size={20} color={navy} />,
          snippet: "The Prophet's Mosque · Floor map",
          body: (
            <div className="space-y-3">
              <div className="rounded-2xl p-4" style={{ background: navy }}>
                <p className="text-xs italic leading-relaxed" style={{ color: "rgba(255,255,255,0.85)" }}>
                  "The area between my house and my minbar is one of the gardens of Paradise"
                </p>
                <p className="text-xs font-bold mt-2" style={{ color: yellow }}>[Bukhari 1196 · Muslim 1391]</p>
              </div>
              <p className="text-xs leading-relaxed" style={{ color: muted }}>Visit with reverence — make du'a, send salawat upon the Prophet ﷺ, and cherish every blessed moment here.</p>
            </div>
          ),
        },
        {
          title: "Jannat al-Baqi",
          icon: <Leaf size={20} color={navy} />,
          snippet: "Main cemetery of Madinah · Adjacent to Nabawi",
          body: (
            <div className="space-y-3">
              <p className="text-xs leading-relaxed" style={{ color: charcoal }}>The main cemetery in Madinah where many of the Prophet's ﷺ family and companions are buried.</p>
              <div className="rounded-xl px-3 py-2.5 flex gap-2.5" style={{ background: sand }}>
                <span className="text-sm">🤲</span>
                <p className="text-xs leading-relaxed" style={{ color: muted }}>Make du'a for those buried here — a powerful reminder of the hereafter.</p>
              </div>
            </div>
          ),
        },
      ],
    },
    {
      label: "Apps & Booking",
      accent: navy,
      accentBg: sand,
      items: [
        {
          title: "Nusuk App",
          icon: <Smartphone size={20} color={navy} />,
          snippet: "Book Rawdah slots · Umrah registration",
          body: (
            <div className="space-y-2.5">
              <p className="text-xs font-semibold" style={{ color: charcoal }}>Book praying in the Rawdah (Prophet's Masjid):</p>
              {[
                "Required to book a place in the Rawdah",
                "Also use it to register your Umrah",
                "Download on Android or iOS",
                "Slots open 7–10 days in advance — book early",
              ].map((t, i) => (
                <div key={i} className="flex gap-2.5 items-start">
                  <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: yellow }} />
                  <p className="text-xs leading-relaxed" style={{ color: muted }}>{t}</p>
                </div>
              ))}
            </div>
          ),
        },
      ],
    },
    {
      label: "On the Ground",
      accent: navy,
      accentBg: sand,
      items: [
        {
          title: "Money & Payments",
          icon: <CreditCard size={20} color={navy} />,
          snippet: "Cards widely accepted · Exchange in Makkah",
          body: (
            <div className="space-y-2.5">
              <div className="grid grid-cols-2 gap-2">
                <div className="rounded-2xl p-3 text-center" style={{ background: sand }}>
                  <p className="text-xl mb-1">💳</p>
                  <p className="text-xs font-semibold" style={{ color: navy }}>Cards OK</p>
                  <p className="text-xs mt-0.5" style={{ color: muted }}>Most shops & ATMs</p>
                </div>
                <div className="rounded-2xl p-3 text-center" style={{ background: sand }}>
                  <p className="text-xl mb-1">💱</p>
                  <p className="text-xs font-semibold" style={{ color: navy }}>Exchange</p>
                  <p className="text-xs mt-0.5" style={{ color: muted }}>Makkah / Madinah only</p>
                </div>
              </div>
              <p className="text-xs leading-relaxed" style={{ color: muted }}>Avoid airport exchange — rates are much better in the city.</p>
            </div>
          ),
        },
        {
          title: "Mobile & Internet",
          icon: <Wifi size={20} color={navy} />,
          snippet: "Airalo eSIM · 3GB · 30 days",
          body: (
            <div className="space-y-2">
              {[
                { step: "1", label: "Register for a free eSIM", sub: "Download the Airalo app" },
                { step: "2", label: "Buy a 3GB data package", sub: "Lasts 30 days — sufficient for the trip" },
                { step: "3", label: "Enable before departure", sub: "Activate in your phone settings" },
              ].map(({ step, label, sub }) => (
                <div key={step} className="flex items-center gap-3 p-3 rounded-xl" style={{ background: sand }}>
                  <div className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-extrabold flex-shrink-0" style={{ background: navy, color: yellow }}>{step}</div>
                  <div>
                    <p className="text-xs font-semibold" style={{ color: charcoal }}>{label}</p>
                    <p className="text-xs" style={{ color: muted }}>{sub}</p>
                  </div>
                </div>
              ))}
            </div>
          ),
        },
        {
          title: "High Speed Train",
          icon: <Navigation size={20} color={navy} />,
          snippet: "Jeddah Airport → Makkah & Madinah",
          body: (
            <div className="space-y-2.5">
              <p className="text-xs leading-relaxed" style={{ color: charcoal }}>The Haramain High Speed Railway connects Jeddah Airport to Makkah and Madinah directly.</p>
              <div className="space-y-2">
                <div className="flex gap-2.5 p-3 rounded-xl" style={{ background: sand }}>
                  <span className="text-sm">📱</span>
                  <div>
                    <p className="text-xs font-semibold" style={{ color: navy }}>Book via HRR Train app</p>
                    <p className="text-xs" style={{ color: muted }}>Cheaper than at-station tickets</p>
                  </div>
                </div>
                <div className="flex gap-2.5 p-3 rounded-xl" style={{ background: sand }}>
                  <span className="text-sm">🚕</span>
                  <div>
                    <p className="text-xs font-semibold" style={{ color: charcoal }}>From station to Haram</p>
                    <p className="text-xs" style={{ color: muted }}>Taxi ~50 Riyal · Shuttle ~6–7 Riyal</p>
                  </div>
                </div>
              </div>
              <p className="text-xs px-1" style={{ color: muted }}>⚠️ Oversized luggage: extra fee, collected 12–24 hrs later.</p>
            </div>
          ),
        },
      ],
    },
  ];

  let idx = 0;
  const flat: { title: string; globalIdx: number }[] = [];
  groups.forEach((g) => {
    g.items.forEach((item) => {
      flat.push({ title: item.title, globalIdx: idx++ });
    });
  });

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      {/* Header */}
      <div className="relative px-4 pt-12 pb-5 overflow-hidden" style={{ background: navy }}>
        <div className="absolute -top-6 -right-6 w-28 h-28 rounded-full opacity-10" style={{ background: yellow }} />
        <button onClick={goBack} className="relative w-8 h-8 flex items-center justify-center rounded-full mb-4" style={{ background: "rgba(255,255,255,0.12)" }}>
          <ArrowLeft size={16} color="white" />
        </button>
        <p className="relative text-xs font-bold uppercase tracking-widest mb-1" style={{ color: yellow }}>Umrah & Hajj</p>
        <h1 className="relative text-xl font-extrabold text-white">Logistics Guide</h1>
        <p className="relative text-xs mt-1" style={{ color: "rgba(255,255,255,0.5)" }}>Visa · Sacred sites · Transport · Practical tips</p>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="px-4 py-5 space-y-6">
          {groups.map((group) => (
            <div key={group.label}>
              {/* Group heading */}
              <div className="flex items-center gap-2 mb-3">
                <div className="w-1 h-4 rounded-full flex-shrink-0" style={{ background: yellow }} />
                <p className="text-xs font-extrabold uppercase tracking-widest" style={{ color: navy }}>{group.label}</p>
              </div>

              {/* Items in group */}
              <div className="space-y-3">
                {group.items.map((item) => {
                  const gi = flat.findIndex(f => f.title === item.title);
                  const isOpen = open === gi;
                  return (
                    <div
                      key={item.title}
                      className="rounded-2xl overflow-hidden"
                      style={{
                        background: white,
                        border: `1px solid ${isOpen ? navy : border}`,
                        boxShadow: isOpen ? "0 2px 12px rgba(11,20,29,0.12)" : "0 1px 6px rgba(11,20,29,0.05)",
                      }}
                    >
                      {/* Row */}
                      <button
                        className="w-full flex items-center gap-3 px-4 py-3.5 text-left"
                        onClick={() => setOpen(isOpen ? null : gi)}
                      >
                        <div className="w-10 h-10 rounded-2xl flex items-center justify-center flex-shrink-0" style={{ background: sand }}>
                          {item.icon}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="font-bold text-sm leading-tight" style={{ color: charcoal }}>{item.title}</p>
                          <p className="text-xs mt-0.5 truncate" style={{ color: muted }}>{item.snippet}</p>
                        </div>
                        <div
                          className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 transition-all duration-200"
                          style={{ background: isOpen ? navy : sand }}
                        >
                          <svg width="10" height="6" viewBox="0 0 10 6" fill="none" style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>
                            <path d="M1 1L5 5L9 1" stroke={isOpen ? white : navy} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                          </svg>
                        </div>
                      </button>

                      {/* Expanded body */}
                      {isOpen && (
                        <div className="px-4 pb-4 pt-1" style={{ borderTop: `1px solid ${border}` }}>
                          {item.body}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          ))}

          {/* Du'a footer */}
          <div className="rounded-3xl px-5 py-5 flex gap-4 items-start" style={{ background: navy }}>
            <span className="text-2xl">🤲</span>
            <div>
              <p className="font-bold text-white text-sm">May Allah accept your worship</p>
              <p className="text-xs mt-1.5 leading-relaxed" style={{ color: "rgba(255,255,255,0.6)" }}>
                Taqabbal Allahu minna wa minkum — May Allah accept from us and from you.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── UMRAH & HAJJ GUIDE ───────────────────────────────────────────────────────
export function UmrahHajjScreen({ goBack, goTo }: { goBack: () => void; goTo: (s: Screen) => void }) {
  const pillars = [
    { arabic: "الإحرام", name: "Ihram", desc: "State of sanctity & intention" },
    { arabic: "الطواف", name: "Tawaf", desc: "7 circuits around the Kaaba" },
    { arabic: "السعي", name: "Sa'i", desc: "Walking between Safa & Marwa" },
    { arabic: "الحلق", name: "Halq", desc: "Shaving or cutting hair" },
  ];

  const hajjSteps = [
    { day: "Day 1", label: "Mina", desc: "Arrive & spend the night in Mina" },
    { day: "Day 2", label: "Arafat", desc: "The pinnacle of Hajj — standing & du'a" },
    { day: "Day 2", label: "Muzdalifah", desc: "Collect pebbles under the night sky" },
    { day: "Day 3+", label: "Rami & Eid", desc: "Stone the Jamarat & sacrifice" },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />

      {/* Header */}
      <div className="flex items-center gap-3 px-5 py-3">
        <BackBtn onBack={goBack} />
        <div>
          <h1 className="font-extrabold text-[18px]" style={{ color: charcoal }}>Umrah &amp; Hajj</h1>
          <p className="text-[11px]" style={{ color: muted }}>Your complete guide to the sacred journey</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-8 px-5 space-y-4">

        {/* Hero */}
        <div className="rounded-[22px] relative overflow-hidden" style={{ background: navy }}>
          <GeoPattern dark id="geo-uh-hero" />
          <div className="relative z-10 px-5 pt-5 pb-5">
            <div className="flex items-center gap-4 mb-4">
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0"
                style={{ background: "rgba(255,196,0,0.15)", border: "1px solid rgba(255,196,0,0.25)" }}
              >
                <TawafIcon size={42} />
              </div>
              <div>
                <p className="text-[11px] font-semibold uppercase tracking-widest mb-0.5" style={{ color: "rgba(255,196,0,0.7)" }}>
                  Sacred Journey
                </p>
                <p className="text-white font-extrabold text-[20px] leading-tight">Umrah &amp; Hajj</p>
              </div>
            </div>
            <p className="text-[13px] leading-relaxed mb-4" style={{ color: "rgba(255,255,255,0.5)" }}>
              Step-by-step guides to the most blessed acts of worship in Islam — from rituals to du'as.
            </p>
            {/* Arabic */}
            <p className="text-[17px] leading-relaxed text-right" style={{ color: "rgba(255,196,0,0.55)", fontFamily: "'Amiri Quran', serif" }}>
              وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ
            </p>
            <p className="text-[10px] mt-1 text-right" style={{ color: "rgba(255,255,255,0.3)" }}>
              "Complete the Hajj and Umrah for Allah" — 2:196
            </p>
          </div>
        </div>

        {/* ── Umrah card ── */}
        <div>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-2.5" style={{ color: muted }}>Start Your Journey</p>
          <button
            onClick={() => goTo("umrah-guide")}
            className="w-full rounded-[20px] overflow-hidden text-left transition-all active:scale-[0.98]"
            style={{ background: white, border: `1px solid ${border}`, boxShadow: "0 2px 12px rgba(0,0,0,0.06)" }}
          >
            {/* Yellow top strip */}
            <div className="h-1.5 w-full" style={{ background: yellow }} />
            <div className="p-4 flex items-center gap-4">
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0"
                style={{ background: "rgba(255,196,0,0.12)" }}
              >
                <TawafIcon size={44} />
              </div>
              <div className="flex-1">
                <p className="text-[10px] font-bold uppercase tracking-widest mb-0.5" style={{ color: yellow }}>Complete Guide</p>
                <p className="font-extrabold text-[17px]" style={{ color: navy }}>Umrah Guide</p>
                <p className="text-[12px] mt-0.5" style={{ color: muted }}>Rituals, du'as &amp; essential tips</p>
              </div>
              <div className="w-9 h-9 rounded-full flex items-center justify-center shrink-0" style={{ background: yellow }}>
                <ChevronRight size={17} color={navy} />
              </div>
            </div>
          </button>
        </div>

        {/* Umrah pillars strip */}
        <div className="grid grid-cols-4 gap-2">
          {pillars.map((p) => (
            <div key={p.name} className="flex flex-col items-center gap-1.5 py-3 px-1 rounded-[14px]" style={{ background: sand, border: `1px solid ${border}` }}>
              <p className="text-[13px]" style={{ color: navy, fontFamily: "'Amiri Quran', serif" }}>{p.arabic}</p>
              <p className="font-bold text-[11px] text-center" style={{ color: charcoal }}>{p.name}</p>
              <p className="text-[9px] text-center leading-tight" style={{ color: muted }}>{p.desc}</p>
            </div>
          ))}
        </div>

        {/* ── Hajj card ── */}
        <button
          onClick={() => goTo("hajj-guide")}
          className="w-full rounded-[20px] overflow-hidden text-left transition-all active:scale-[0.98]"
          style={{ background: navy, boxShadow: "0 2px 12px rgba(11,20,29,0.2)" }}
        >
          <div className="p-4 flex items-center gap-4">
            <div
              className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0"
              style={{ background: "rgba(255,196,0,0.15)", border: "1px solid rgba(255,196,0,0.2)" }}
            >
              <ArafatIcon size={44} />
            </div>
            <div className="flex-1">
              <p className="text-[10px] font-bold uppercase tracking-widest mb-0.5" style={{ color: "rgba(255,196,0,0.7)" }}>Complete Guide</p>
              <p className="font-extrabold text-[17px] text-white">Hajj Guide</p>
              <p className="text-[12px] mt-0.5" style={{ color: "rgba(255,255,255,0.45)" }}>Pillars, locations &amp; rituals</p>
            </div>
            <div className="w-9 h-9 rounded-full flex items-center justify-center shrink-0" style={{ background: yellow }}>
              <ChevronRight size={17} color={navy} />
            </div>
          </div>
        </button>

        {/* Hajj timeline */}
        <div>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-2.5" style={{ color: muted }}>Hajj at a Glance</p>
          <div className="rounded-[18px] overflow-hidden" style={{ border: `1px solid ${border}` }}>
            {hajjSteps.map((s, i) => (
              <div
                key={s.label}
                className="flex items-center gap-3 px-4 py-3"
                style={{
                  background: i % 2 === 0 ? white : sand,
                  borderBottom: i < hajjSteps.length - 1 ? `1px solid ${border}` : "none",
                }}
              >
                <div
                  className="shrink-0 px-2 py-1 rounded-lg text-[9px] font-bold text-center"
                  style={{ background: "rgba(255,196,0,0.15)", color: "#A16207", minWidth: 36 }}
                >
                  {s.day}
                </div>
                <div className="flex-1">
                  <p className="font-bold text-[13px]" style={{ color: charcoal }}>{s.label}</p>
                  <p className="text-[11px]" style={{ color: muted }}>{s.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Explore more */}
        <div>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-2.5" style={{ color: muted }}>Explore More</p>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: "Spiritual Preparation", Icon: DuaHandsIcon, desc: "Intention, du'a & heart", screen: "spiritual-prep" as Screen },
              { label: "Visiting Madinah", Icon: MadinahDomeIcon, desc: "The Prophet's city ﷺ" },
              { label: "Logistics", Icon: LogisticsIcon, desc: "Travel, packing, tips", screen: "logistics" as Screen },
              { label: "FAQ", Icon: FAQBubbleIcon, desc: "Common questions", screen: "faq" as Screen },
            ].map(({ label, Icon, desc, screen: s }) => (
              <button
                key={label}
                onClick={() => s && goTo(s)}
                className="rounded-[18px] p-4 text-left transition-all active:scale-95"
                style={{ background: white, border: `1px solid ${border}` }}
              >
                <div
                  className="w-11 h-11 rounded-[14px] flex items-center justify-center mb-3"
                  style={{ background: sand }}
                >
                  <Icon size={28} />
                </div>
                <p className="font-bold text-[13px] leading-snug" style={{ color: charcoal }}>{label}</p>
                <p className="text-[11px] mt-0.5" style={{ color: muted }}>{desc}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Scholarly note */}
        <div
          className="flex items-start gap-3 px-4 py-3.5 rounded-[16px]"
          style={{ background: "rgba(255,196,0,0.08)", border: "1px solid rgba(255,196,0,0.2)" }}
        >
          <div className="w-8 h-8 rounded-xl flex items-center justify-center shrink-0 mt-0.5" style={{ background: yellow }}>
            <BookOpen size={15} color={navy} />
          </div>
          <p className="text-[12px] leading-relaxed" style={{ color: muted }}>
            All guides are based on authentic scholarly sources. Always consult a qualified scholar for personal rulings.
          </p>
        </div>

      </div>
    </div>
  );
}
