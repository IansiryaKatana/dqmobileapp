import React from "react";
import { ArrowLeft, Home, BookOpen, Compass, Heart, Menu } from "lucide-react";
import type { Tab } from "./types";
import { navy, yellow, cream, sand, white, charcoal, muted, border } from "./context";

// ─── Islamic geometric SVG pattern ───────────────────────────────────────────
export function GeoPattern({ dark = true, id = "geo" }: { dark?: boolean; id?: string }) {
  const stroke = dark ? white : charcoal;
  const opacity = dark ? 0.05 : 0.06;
  return (
    <svg className="absolute inset-0 w-full h-full pointer-events-none" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <pattern id={id} x="0" y="0" width="72" height="72" patternUnits="userSpaceOnUse">
          <path
            d="M36 4 L42 18 L56 12 L50 26 L64 24 L54 34 L64 44 L50 42 L56 56 L42 50 L36 64 L30 50 L16 56 L22 42 L8 44 L18 34 L8 24 L22 26 L16 12 L30 18 Z"
            fill="none"
            stroke={stroke}
            strokeWidth="0.5"
            opacity={opacity}
          />
          <circle cx="36" cy="36" r="3" fill="none" stroke={stroke} strokeWidth="0.4" opacity={opacity * 0.6} />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill={`url(#${id})`} />
    </svg>
  );
}

// ─── Logo wordmark ────────────────────────────────────────────────────────────
export function Logo({ size = "md", light = false }: { size?: "sm" | "md" | "lg"; light?: boolean }) {
  const fs = size === "lg" ? "text-2xl" : size === "sm" ? "text-base" : "text-xl";
  return (
    <span className={`font-bold tracking-tight ${fs}`}>
      <span style={{ color: light ? white : navy }}>Donate</span>
      <span style={{ color: yellow }}> Quran</span>
    </span>
  );
}

// ─── Status bar ───────────────────────────────────────────────────────────────
export function StatusBar({ dark = false }: { dark?: boolean }) {
  const color = dark ? "rgba(255,255,255,0.6)" : muted;
  return (
    <div className="flex items-center justify-between px-6 pt-4 pb-1 text-xs font-semibold select-none" style={{ color }}>
      <span>9:41</span>
      <div className="flex items-center gap-1.5">
        <svg width="16" height="10" viewBox="0 0 16 10" fill={color}>
          <rect x="0" y="5" width="3" height="5" rx="0.5" opacity="0.4" />
          <rect x="4.5" y="3" width="3" height="7" rx="0.5" opacity="0.6" />
          <rect x="9" y="1" width="3" height="9" rx="0.5" opacity="0.8" />
          <rect x="13.5" y="0" width="3" height="10" rx="0.5" />
        </svg>
        <svg width="14" height="10" viewBox="0 0 14 10" fill={color}>
          <path d="M7 2C9.2 2 11.2 3 12.6 4.6L14 3.1C12.2 1.2 9.7 0 7 0S1.8 1.2 0 3.1L1.4 4.6C2.8 3 4.8 2 7 2Z" />
          <path d="M7 5C8.3 5 9.5 5.5 10.4 6.4L11.8 4.9C10.5 3.7 8.8 3 7 3S3.5 3.7 2.2 4.9L3.6 6.4C4.5 5.5 5.7 5 7 5Z" opacity="0.7" />
          <circle cx="7" cy="8.5" r="1.5" />
        </svg>
        <span style={{ color }}>100%</span>
      </div>
    </div>
  );
}

// ─── Back button ──────────────────────────────────────────────────────────────
export function BackBtn({ onBack, dark = false }: { onBack: () => void; dark?: boolean }) {
  return (
    <button
      onClick={onBack}
      className="w-9 h-9 rounded-full flex items-center justify-center shrink-0"
      style={{
        background: dark ? "rgba(255,255,255,0.09)" : sand,
        border: `1px solid ${dark ? "rgba(255,255,255,0.1)" : border}`,
      }}
    >
      <ArrowLeft size={17} color={dark ? white : charcoal} />
    </button>
  );
}

// ─── Yellow CTA button ────────────────────────────────────────────────────────
export function CTA({ label, onClick, className = "" }: { label: string; onClick?: () => void; className?: string }) {
  return (
    <button
      onClick={onClick}
      className={`w-full py-4 rounded-2xl font-semibold text-[15px] tracking-tight ${className}`}
      style={{ background: yellow, color: navy }}
    >
      {label}
    </button>
  );
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────
export function BottomNav({ active, onNav }: { active: Tab; onNav: (t: Tab) => void }) {
  const tabs: { id: Tab; icon: React.FC<{ size: number; color: string }>; label: string }[] = [
    { id: "home",  icon: (p) => <Home  {...p} />, label: "Home"   },
    { id: "quran", icon: (p) => <BookOpen {...p} />, label: "Quran" },
    { id: "qibla", icon: (p) => <Compass {...p} />, label: "Qibla" },
    { id: "saved", icon: (p) => <Heart  {...p} />, label: "Saved" },
    { id: "more",  icon: (p) => <Menu   {...p} />, label: "More"  },
  ];
  return (
    <div
      className="flex items-center justify-around px-2 pb-6 pt-2"
      style={{ background: white, borderTop: `1px solid ${border}` }}
    >
      {tabs.map(({ id, icon: Icon, label }) => {
        const isActive = active === id;
        return (
          <button
            key={id}
            onClick={() => onNav(id)}
            className="flex flex-col items-center gap-1 px-3 pt-1"
          >
            <Icon size={22} color={isActive ? navy : muted} />
            <span className="text-[10px] font-semibold" style={{ color: isActive ? navy : muted }}>{label}</span>
            {isActive && <div className="w-1 h-1 rounded-full" style={{ background: yellow }} />}
          </button>
        );
      })}
    </div>
  );
}

// ─── Ghost CTA ────────────────────────────────────────────────────────────────
export function GhostCTA({ label, onClick }: { label: string; onClick?: () => void }) {
  return (
    <button
      onClick={onClick}
      className="w-full py-4 rounded-2xl font-semibold text-[15px]"
      style={{ background: "rgba(255,255,255,0.09)", color: white, border: "1px solid rgba(255,255,255,0.14)" }}
    >
      {label}
    </button>
  );
}
