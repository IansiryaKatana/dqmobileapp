import { useState, useRef, useEffect } from "react";
import { motion } from "motion/react";
import {
  ChevronRight, ArrowLeft, Play, Pause, Bookmark,
  Share2, Moon, Sun, Home, BookOpen, Compass, Heart, Menu,
  Search, User, Globe, Lock, HelpCircle, Package, MapPin,
  Plus, Minus, Check, Eye, EyeOff, LogOut, Languages, Bell,
  Sparkles, Droplets, MessageCircle,
} from "lucide-react";
import { ImageWithFallback } from "@/app/components/figma/ImageWithFallback";
import donateQuranLogo from "@/imports/image.png";
import quranBookshot from "@/imports/ChatGPT_Image_Jul_8__2026__04_21_36_PM.png";
import type { Screen, Tab } from "./types";
import { useApp, useT, navy, yellow, cream, sand, white, charcoal, muted, border } from "./context";
import { GeoPattern, Logo, StatusBar, BackBtn, CTA, GhostCTA } from "./shared";

let impactHasAnimated = false;

export function HomeScreen({ onNav, goTo }: { onNav: (t: Tab) => void; goTo: (s: Screen) => void }) {
  const TARGETS = [12847, 3291, 47];
  const LABELS  = ["Qurans Funded", "Orders Placed", "Countries"];
  const [counts, setCounts] = useState(impactHasAnimated ? TARGETS : [0, 0, 0]);
  const impactRaf = useRef<number>(0);

  useEffect(() => {
    if (impactHasAnimated) return;
    impactHasAnimated = true;
    const t0 = Date.now();
    const dur = 2000;
    const tick = () => {
      const p = Math.min((Date.now() - t0) / dur, 1);
      const e = 1 - Math.pow(1 - p, 3);
      setCounts(TARGETS.map((t) => Math.round(e * t)));
      if (p < 1) impactRaf.current = requestAnimationFrame(tick);
      else setCounts(TARGETS);
    };
    impactRaf.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(impactRaf.current);
  }, []);

  const fmt = (n: number) => n.toLocaleString();

  const quickActions = [
    { label: "Qibla", icon: Compass, action: () => onNav("qibla") },
    { label: "Ask Scholar", icon: HelpCircle, action: () => goTo("ask-scholar") },
    { label: "How to Pray", icon: Compass, action: () => goTo("how-to-pray") },
    { label: "Books & Articles", icon: BookOpen, action: () => goTo("learn") },
  ];
  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />
      <div className="flex items-center justify-between px-5 py-2.5">
        <Logo />
        <button
          className="w-9 h-9 rounded-full flex items-center justify-center"
          style={{ background: sand, border: `1px solid ${border}` }}
          onClick={() => goTo("profile")}
        >
          <User size={17} color={charcoal} />
        </button>
      </div>
      <div className="flex-1 overflow-y-auto pb-28 px-5 space-y-3.5">
        {/* Product shot */}
        <div className="rounded-[20px] overflow-hidden relative" style={{ background: "#111", height: 130 }}>
          <ImageWithFallback
            src={quranBookshot}
            alt="The Quran — Donate Quran"
            className="w-full h-full object-cover"
          />
          {/* Read Quran label */}
          <div className="absolute bottom-0 left-0 right-0 px-4 py-3 flex items-center justify-between"
               style={{ background: "linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 100%)" }}>
            <span className="text-white font-bold text-[15px] tracking-tight">Read Quran</span>
            <button
              onClick={() => goTo("quran")}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[12px] font-semibold"
              style={{ background: yellow, color: navy }}
            >
              Open <ChevronRight size={13} />
            </button>
          </div>
        </div>

        {/* Hero card */}
        <div className="rounded-[24px] p-5 relative overflow-hidden" style={{ background: navy }}>
          <GeoPattern dark id="geo-home" />
          <div className="relative z-10">
            <span
              className="inline-block px-3 py-1 rounded-full text-[11px] font-semibold mb-3"
              style={{ background: "rgba(255,196,0,0.14)", color: yellow }}
            >
              Donate Quran
            </span>
            <h2 className="text-white text-[22px] font-extrabold leading-snug mb-1.5">
              Share the Quran.<br />Earn ongoing reward.
            </h2>
            <p className="text-[13px] mb-5 leading-relaxed" style={{ color: "rgba(255,255,255,0.5)" }}>
              Donate, order a free Quran, read, learn and support distribution worldwide.
            </p>
            <div className="flex gap-2.5">
              <button
                onClick={() => goTo("donate")}
                className="flex-1 py-3 rounded-2xl text-[13px] font-bold"
                style={{ background: yellow, color: navy }}
              >
                Donate Now
              </button>
              <button
                onClick={() => goTo("order")}
                className="flex-1 py-3 rounded-2xl text-[13px] font-semibold"
                style={{ background: "rgba(255,255,255,0.09)", color: white, border: "1px solid rgba(255,255,255,0.14)" }}
              >
                Order Free
              </button>
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div className="grid grid-cols-4 gap-2">
          {quickActions.map(({ label, icon: Icon, action }) => (
            <button
              key={label}
              onClick={action}
              className="flex flex-col items-center gap-2 py-3 rounded-[16px] transition-all active:scale-95"
              style={{ background: sand, border: `1px solid ${border}` }}
            >
              <div
                className="w-9 h-9 rounded-xl flex items-center justify-center"
                style={{ background: white }}
              >
                <Icon size={18} color={navy} />
              </div>
              <span className="text-[10px] font-semibold text-center leading-tight" style={{ color: charcoal }}>
                {label}
              </span>
            </button>
          ))}
        </div>

        {/* Impact — animated counters */}
        <div className="rounded-[20px] p-4" style={{ background: white, border: `1px solid ${border}` }}>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-3" style={{ color: muted }}>Our Impact</p>
          <div className="grid grid-cols-3" style={{ borderColor: border }}>
            {TARGETS.map((_, i) => (
              <div
                key={LABELS[i]}
                className="text-center px-2"
                style={{ borderRight: i < 2 ? `1px solid ${border}` : "none" }}
              >
                <p
                  className="font-extrabold leading-none"
                  style={{ color: yellow, fontSize: 22, fontVariantNumeric: "tabular-nums" }}
                >
                  {fmt(counts[i])}
                </p>
                <p className="text-[10px] leading-tight mt-1" style={{ color: muted }}>{LABELS[i]}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Campaign */}
        <div
          className="rounded-[20px] p-4 flex items-center justify-between"
          style={{ background: navy, border: "1px solid rgba(255,196,0,0.12)" }}
        >
          <div>
            <p className="text-[11px] mb-1" style={{ color: "rgba(255,255,255,0.4)" }}>Featured Campaign</p>
            <p className="text-white font-bold text-[14px]">Support Quran Printing</p>
            <p className="text-[12px] mt-0.5" style={{ color: yellow }}>2,340 copies funded so far</p>
          </div>
          <button
            onClick={() => goTo("donate")}
            className="px-4 py-2.5 rounded-2xl text-[12px] font-bold shrink-0"
            style={{ background: yellow, color: navy }}
          >
            Sponsor
          </button>
        </div>

        {/* New Muslim */}
        <div
          className="rounded-[20px] p-4 flex items-center justify-between"
          style={{ background: sand, border: `1px solid ${border}` }}
        >
          <div>
            <p className="text-[11px] mb-1" style={{ color: muted }}>Learning Path</p>
            <p className="font-bold text-[14px]" style={{ color: charcoal }}>New to Islam?</p>
            <p className="text-[12px] mt-0.5" style={{ color: muted }}>Begin your journey here</p>
          </div>
          <button
            onClick={() => goTo("new-muslim")}
            className="px-4 py-2.5 rounded-2xl text-[12px] font-bold shrink-0"
            style={{ background: navy, color: white }}
          >
            Start Here
          </button>
        </div>
      </div>
    </div>
  );
}

// Donate
export function DonateScreen({ goBack, goTo }: { goBack: () => void; goTo: (s: Screen) => void }) {
  const [amount, setAmount] = useState(25);
  const [custom, setCustom] = useState("");
  const [freq, setFreq] = useState<"once" | "monthly">("once");
  const amounts = [5, 10, 25, 50, 100];
  const impacts = [
    { label: "Sponsor 1 Quran", copies: 1, price: 5 },
    { label: "Sponsor 5 Qurans", copies: 5, price: 25 },
    { label: "Sponsor 10 Qurans", copies: 10, price: 50 },
    { label: "Sponsor a Box", copies: 50, price: 250 },
  ];
  const displayAmt = custom ? `£${custom}` : `£${amount}`;
  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />
      <div className="flex items-center gap-3 px-5 py-2.5">
        <BackBtn onBack={goBack} />
        <h1 className="font-bold text-lg" style={{ color: charcoal }}>Donate</h1>
      </div>
      <div className="flex-1 overflow-y-auto pb-28 px-5 space-y-4">
        <div className="rounded-[24px] p-5 relative overflow-hidden" style={{ background: navy }}>
          <GeoPattern dark id="geo-donate" />
          <div className="relative z-10">
            <p className="text-white text-xl font-extrabold">Fund Quran printing today</p>
            <p className="text-[13px] mt-1" style={{ color: "rgba(255,255,255,0.5)" }}>
              Every £5 funds one Quran copy.
            </p>
          </div>
        </div>
        {/* Frequency */}
        <div className="flex rounded-2xl p-1 gap-1" style={{ background: sand, border: `1px solid ${border}` }}>
          {(["once", "monthly"] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFreq(f)}
              className="flex-1 py-2.5 rounded-xl text-[13px] font-bold capitalize transition-all"
              style={{ background: freq === f ? yellow : "transparent", color: freq === f ? navy : muted }}
            >
              {f === "once" ? "One-time" : "Monthly"}
            </button>
          ))}
        </div>
        {/* Amounts */}
        <div>
          <p className="text-[13px] font-bold mb-2.5" style={{ color: charcoal }}>Select amount</p>
          <div className="grid grid-cols-3 gap-2">
            {amounts.map((a) => {
              const sel = amount === a && !custom;
              return (
                <button
                  key={a}
                  onClick={() => { setAmount(a); setCustom(""); }}
                  className="py-3 rounded-2xl text-[14px] font-bold transition-all"
                  style={{
                    background: sel ? yellow : sand,
                    color: sel ? navy : charcoal,
                    border: `1.5px solid ${sel ? yellow : border}`,
                  }}
                >
                  £{a}
                </button>
              );
            })}
            <button
              onClick={() => setAmount(0)}
              className="py-3 rounded-2xl text-[14px] font-bold transition-all"
              style={{
                background: custom ? yellow : sand,
                color: custom ? navy : charcoal,
                border: `1.5px solid ${custom ? yellow : border}`,
              }}
            >
              Custom
            </button>
          </div>
          {amount === 0 && (
            <input
              value={custom}
              onChange={(e) => setCustom(e.target.value.replace(/[^0-9.]/g, ""))}
              placeholder="Enter amount £"
              className="w-full mt-2.5 py-3 px-4 rounded-2xl text-[14px] outline-none"
              style={{ background: sand, border: `1px solid ${border}`, color: charcoal }}
            />
          )}
        </div>
        {/* Impact */}
        <div>
          <p className="text-[13px] font-bold mb-2.5" style={{ color: charcoal }}>Your impact</p>
          <div className="space-y-2">
            {impacts.map((i) => (
              <div
                key={i.label}
                className="flex items-center justify-between px-4 py-3 rounded-[16px]"
                style={{ background: white, border: `1px solid ${border}` }}
              >
                <div>
                  <p className="text-[13px] font-semibold" style={{ color: charcoal }}>{i.label}</p>
                  <p className="text-[11px] mt-0.5" style={{ color: muted }}>{i.copies} cop{i.copies === 1 ? "y" : "ies"} distributed</p>
                </div>
                <span className="text-[16px] font-extrabold" style={{ color: yellow }}>£{i.price}</span>
              </div>
            ))}
          </div>
        </div>
        {/* Trust */}
        <div className="flex items-start gap-3 px-4 py-3 rounded-[16px]" style={{ background: sand, border: `1px solid ${border}` }}>
          <Check size={15} color={navy} className="mt-0.5 shrink-0" />
          <p className="text-[12px] leading-relaxed" style={{ color: muted }}>
            100% of public donations go towards Quran printing and distribution.
          </p>
        </div>
      </div>
      <div className="absolute bottom-0 left-0 right-0 px-5 pb-6 pt-3" style={{ background: cream, borderTop: `1px solid ${border}` }}>
        <CTA label={`Continue — ${displayAmt}`} onClick={() => goTo("donate-checkout")} />
      </div>
    </div>
  );
}

// Donate Checkout
export function DonateCheckout({ goBack, goTo }: { goBack: () => void; goTo: (s: Screen) => void }) {
  const [pay, setPay] = useState<"apple" | "card" | "bank">("apple");
  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />
      <div className="flex items-center gap-3 px-5 py-2.5">
        <BackBtn onBack={goBack} />
        <h1 className="font-bold text-lg" style={{ color: charcoal }}>Checkout</h1>
      </div>
      <div className="flex-1 overflow-y-auto pb-28 px-5 space-y-4">
        {/* Summary */}
        <div className="rounded-[20px] p-4" style={{ background: white, border: `1px solid ${border}` }}>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-3" style={{ color: muted }}>Donation Summary</p>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-bold text-[15px]" style={{ color: charcoal }}>One-time Donation</p>
              <p className="text-[12px] mt-0.5" style={{ color: muted }}>Quran Printing Fund</p>
            </div>
            <p className="text-[28px] font-extrabold" style={{ color: yellow }}>£25</p>
          </div>
        </div>
        {/* Details */}
        <div className="rounded-[20px] p-4 space-y-3" style={{ background: white, border: `1px solid ${border}` }}>
          <p className="text-[10px] font-bold uppercase tracking-widest" style={{ color: muted }}>Your Details</p>
          {["Full Name", "Email Address"].map((p) => (
            <input
              key={p}
              placeholder={p}
              className="w-full py-3 px-4 rounded-2xl text-[14px] outline-none"
              style={{ background: cream, border: `1px solid ${border}`, color: charcoal }}
            />
          ))}
          <label className="flex items-center gap-2.5 cursor-pointer">
            <div className="w-5 h-5 rounded-md" style={{ background: sand, border: `1px solid ${border}` }} />
            <span className="text-[13px]" style={{ color: muted }}>Donate on behalf of someone</span>
          </label>
        </div>
        {/* Payment */}
        <div className="rounded-[20px] p-4" style={{ background: white, border: `1px solid ${border}` }}>
          <p className="text-[10px] font-bold uppercase tracking-widest mb-3" style={{ color: muted }}>Payment Method</p>
          <div className="space-y-2">
            {[
              { id: "apple" as const, label: "Apple Pay", emoji: "🍎" },
              { id: "card" as const, label: "Card", emoji: "💳" },
              { id: "bank" as const, label: "Bank Transfer", emoji: "🏦" },
            ].map((m) => {
              const sel = pay === m.id;
              return (
                <button
                  key={m.id}
                  onClick={() => setPay(m.id)}
                  className="w-full flex items-center justify-between px-4 py-3 rounded-2xl transition-all"
                  style={{
                    background: sel ? "rgba(255,196,0,0.08)" : cream,
                    border: `1.5px solid ${sel ? yellow : border}`,
                  }}
                >
                  <span className="text-[14px] font-medium" style={{ color: charcoal }}>
                    {m.emoji} &nbsp;{m.label}
                  </span>
                  <div
                    className="w-5 h-5 rounded-full flex items-center justify-center"
                    style={{ border: `2px solid ${sel ? yellow : border}`, background: sel ? yellow : "transparent" }}
                  >
                    {sel && <div className="w-2 h-2 rounded-full" style={{ background: white }} />}
                  </div>
                </button>
              );
            })}
          </div>
        </div>
        <div className="flex items-start gap-3 px-4 py-3 rounded-[16px]" style={{ background: sand, border: `1px solid ${border}` }}>
          <Lock size={14} color={muted} className="mt-0.5 shrink-0" />
          <p className="text-[12px] leading-relaxed" style={{ color: muted }}>
            Secured by 256-bit encryption. Your payment details are never stored.
          </p>
        </div>
      </div>
      <div className="absolute bottom-0 left-0 right-0 px-5 pb-6 pt-3" style={{ background: cream, borderTop: `1px solid ${border}` }}>
        <CTA label="Donate Now — £25" onClick={() => goTo("donate-success")} />
      </div>
    </div>
  );
}

// Donate Success
export function DonateSuccess({ onHome }: { onHome: () => void }) {
  const ref = `#DQ-${Math.floor(Math.random() * 90000 + 10000)}`;
  return (
    <div className="flex flex-col h-full relative overflow-hidden" style={{ background: navy }}>
      <GeoPattern dark id="geo-dsuccess" />
      <StatusBar dark />
      <div className="relative z-10 flex-1 flex flex-col items-center justify-center px-7 text-center gap-6">
        <div
          className="w-20 h-20 rounded-full flex items-center justify-center"
          style={{ background: "rgba(255,196,0,0.13)", border: "1px solid rgba(255,196,0,0.28)" }}
        >
          <Check size={34} color={yellow} />
        </div>
        <div>
          <h1 className="text-[26px] font-extrabold text-white mb-2">May Allah reward you</h1>
          <p className="text-[14px] leading-relaxed" style={{ color: "rgba(255,255,255,0.5)" }}>
            Your donation has been received and will go towards Quran printing.
          </p>
        </div>
        <div className="w-full rounded-[20px] p-4" style={{ background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)" }}>
          <div className="flex justify-between mb-3">
            <p className="text-[11px]" style={{ color: "rgba(255,255,255,0.45)" }}>Receipt</p>
            <p className="text-[11px]" style={{ color: "rgba(255,255,255,0.35)" }}>{ref}</p>
          </div>
          {[["Amount", "£25.00"], ["Type", "One-time"], ["Fund", "Quran Printing"]].map(([k, v]) => (
            <div key={k} className="flex justify-between py-2.5" style={{ borderTop: "1px solid rgba(255,255,255,0.07)" }}>
              <span className="text-[13px]" style={{ color: "rgba(255,255,255,0.45)" }}>{k}</span>
              <span className="text-[13px] font-semibold text-white">{v}</span>
            </div>
          ))}
        </div>
        <div className="w-full space-y-2.5">
          <CTA label="View Receipt" />
          <GhostCTA label="Share Campaign" />
          <button onClick={onHome} className="w-full py-3 text-[13px]" style={{ color: "rgba(255,255,255,0.4)" }}>
            Back to Home
          </button>
        </div>
      </div>
    </div>
  );
}

// Order
export function OrderScreen({ goBack, goTo }: { goBack: () => void; goTo: (s: Screen) => void }) {
  const products = [
    { title: "1 Free Quran Copy", desc: "For personal use or to share", qty: "1 copy", cta: "Order Free" },
    { title: "2–9 Copies", desc: "Share with family and friends", qty: "2–9 copies", cta: "Order Now" },
    { title: "Bulk Order 10+", desc: "For mosques and organisations", qty: "10+ copies", cta: "Bulk Order" },
    { title: "Pallet Order", desc: "Large-scale distribution", qty: "100+ copies", cta: "Get in Touch" },
  ];
  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />
      <div className="flex items-center gap-3 px-5 py-2.5">
        <BackBtn onBack={goBack} />
        <h1 className="font-bold text-lg" style={{ color: charcoal }}>Order Free Quran</h1>
      </div>
      <div className="flex-1 overflow-y-auto pb-8 px-5 space-y-3.5">
        <div className="rounded-[24px] p-5 relative overflow-hidden" style={{ background: navy }}>
          <GeoPattern dark id="geo-order" />
          <div className="relative z-10">
            <p className="text-white text-xl font-extrabold">Receive or share a free Quran copy</p>
            <p className="text-[13px] mt-1" style={{ color: "rgba(255,255,255,0.5)" }}>
              Quran copies are free. Postage and packaging may apply.
            </p>
          </div>
        </div>
        {products.map((p) => (
          <div
            key={p.title}
            className="rounded-[20px] p-4 flex items-center justify-between"
            style={{ background: white, border: `1px solid ${border}` }}
          >
            <div className="flex-1 mr-4">
              <p className="font-bold text-[14px]" style={{ color: charcoal }}>{p.title}</p>
              <p className="text-[12px] mt-0.5" style={{ color: muted }}>{p.desc}</p>
              <span
                className="inline-block mt-2 px-2.5 py-1 rounded-full text-[11px] font-medium"
                style={{ background: sand, color: muted }}
              >
                {p.qty}
              </span>
            </div>
            <button
              onClick={() => goTo("order-detail")}
              className="px-4 py-2.5 rounded-2xl text-[12px] font-bold shrink-0"
              style={{ background: yellow, color: navy }}
            >
              {p.cta}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

// Order Detail
export function OrderDetail({ goBack, goTo }: { goBack: () => void; goTo: (s: Screen) => void }) {
  const [qty, setQty] = useState(1);
  const [lang, setLang] = useState<"english" | "arabic">("english");
  return (
    <div className="flex flex-col h-full" style={{ background: cream }}>
      <StatusBar />
      <div className="flex items-center gap-3 px-5 py-2.5">
        <BackBtn onBack={goBack} />
        <h1 className="font-bold text-lg" style={{ color: charcoal }}>Quran Copy</h1>
      </div>
      <div className="flex-1 overflow-y-auto pb-28 px-5 space-y-4">
        <div className="w-full h-52 rounded-[24px] flex items-center justify-center relative overflow-hidden" style={{ background: navy }}>
          <GeoPattern dark id="geo-detail" />
          <div className="relative z-10 flex flex-col items-center gap-3 text-center">
            <div
              className="w-20 h-24 rounded-[14px] flex items-center justify-center"
              style={{ background: "rgba(255,196,0,0.12)", border: "1px solid rgba(255,196,0,0.2)" }}
            >
              <BookOpen size={40} color={yellow} strokeWidth={1.3} />
            </div>
            <p className="text-white font-bold">The Noble Quran</p>
            <p className="text-[11px]" style={{ color: "rgba(255,255,255,0.4)" }}>English Translation</p>
          </div>
        </div>
        <div>
          <h2 className="text-[22px] font-extrabold mb-1" style={{ color: charcoal }}>1 Free Quran Copy</h2>
          <p className="text-[13px]" style={{ color: muted }}>
            Quran copies are free. Postage and packaging may apply.
          </p>
        </div>
        <div>
          <p className="text-[13px] font-bold mb-2.5" style={{ color: charcoal }}>Language</p>
          <div className="flex gap-2">
            {(["english", "arabic"] as const).map((l) => (
              <button
                key={l}
                onClick={() => setLang(l)}
                className="px-5 py-2.5 rounded-2xl text-[13px] font-semibold capitalize"
                style={{
                  background: lang === l ? yellow : sand,
                  color: lang === l ? navy : muted,
                  border: `1.5px solid ${lang === l ? yellow : border}`,
                }}
              >
                {l}
              </button>
            ))}
          </div>
        </div>
        <div>
          <p className="text-[13px] font-bold mb-2.5" style={{ color: charcoal }}>Quantity</p>
          <div className="flex items-center gap-5">
            <button
              onClick={() => setQty(Math.max(1, qty - 1))}
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ background: sand, border: `1px solid ${border}` }}
            >
              <Minus size={17} color={charcoal} />
            </button>
            <span className="text-[22px] font-extrabold w-8 text-center" style={{ color: charcoal }}>{qty}</span>
            <button
              onClick={() => setQty(qty + 1)}
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ background: sand, border: `1px solid ${border}` }}
            >
              <Plus size={17} color={charcoal} />
            </button>
          </div>
        </div>
        <div className="flex items-start gap-3 px-4 py-3 rounded-[16px]" style={{ background: sand, border: `1px solid ${border}` }}>
          <Package size={14} color={muted} className="mt-0.5 shrink-0" />
          <p className="text-[12px] leading-relaxed" style={{ color: muted }}>
            Estimated delivery: 3–7 business days within the UK.
          </p>
        </div>
      </div>
      <div className="absolute bottom-0 left-0 right-0 px-5 pb-6 pt-3" style={{ background: cream, borderTop: `1px solid ${border}` }}>
        <CTA label={`Add to Order — ${qty} cop${qty === 1 ? "y" : "ies"}`} onClick={() => goTo("order-success")} />
      </div>
    </div>
  );
}

// Order Success
export function OrderSuccess({ onHome }: { onHome: () => void }) {
  const ref = `#DQO-${Math.floor(Math.random() * 90000 + 10000)}`;
  return (
    <div className="flex flex-col h-full relative overflow-hidden" style={{ background: navy }}>
      <GeoPattern dark id="geo-osuccess" />
      <StatusBar dark />
      <div className="relative z-10 flex-1 flex flex-col items-center justify-center px-7 text-center gap-6">
        <div
          className="w-20 h-20 rounded-full flex items-center justify-center"
          style={{ background: "rgba(255,196,0,0.13)", border: "1px solid rgba(255,196,0,0.28)" }}
        >
          <Package size={34} color={yellow} />
        </div>
        <div>
          <h1 className="text-[24px] font-extrabold text-white mb-2">
            Your Quran order has been received
          </h1>
          <p className="text-[13px] leading-relaxed" style={{ color: "rgba(255,255,255,0.5)" }}>
            We will keep you updated on your order.
          </p>
        </div>
        <div className="w-full rounded-[20px] p-5 text-center" style={{ background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)" }}>
          <p className="text-[11px] mb-2" style={{ color: "rgba(255,255,255,0.4)" }}>Order Reference</p>
          <p className="text-[28px] font-extrabold" style={{ color: yellow }}>{ref}</p>
        </div>
        <div className="w-full space-y-2.5">
          <CTA label="Track Order" />
          <button onClick={onHome} className="w-full py-3 text-[13px]" style={{ color: "rgba(255,255,255,0.4)" }}>
            Back to Home
          </button>
        </div>
      </div>
    </div>
  );
}

// Quran Home

