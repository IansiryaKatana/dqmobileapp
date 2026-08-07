import { useState, useEffect } from "react";
import type { Screen, Tab } from "./types";
import { AppCtx, AppCtxType, AppUser, useApp, navy, yellow, cream, white } from "./context";
import { SplashScreen, Onboard1, Onboard2 } from "./onboardScreens";
import { HomeScreen, DonateScreen, DonateCheckout, DonateSuccess, OrderScreen, OrderDetail, OrderSuccess } from "./mainScreens";
import { QuranHome, QuranReader, QiblaScreen, SavedScreen, MoreScreen } from "./contentScreens";
import { LoginScreen, SignupScreen, LanguageSelectScreen } from "./authScreens";
import { AskScholar, NewMuslimScreen, WhatIsIslamScreen, WhatIsQuranScreen, WhoIsProphetScreen, HowToPrayScreen, LearnScreen, AboutUsScreen, BooksArticlesScreen, LEARN_ARTICLES, Article } from "./learnScreens";
import { KaabaIcon, KaabaAerialIcon, FAQScreen, HajjGuideScreen, SpiritualPrepScreen } from "./hajjScreens";
import { UmrahGuideScreen, LogisticsScreen, UmrahHajjScreen } from "./umrahScreens";
import { WuduGuideScreen } from "./wuduScreen";
import { ProfileScreen, DonationHistoryScreen, OrderHistoryScreen, ReceiptsScreen, BookmarksScreen, ReadingProgressScreen, PrivacyPolicyScreen, TermsConditionsScreen } from "./profileScreens";
import { BottomNav } from "./shared";

export default function App() {
  const [stack, setStack] = useState<Screen[]>(["splash"]);
  const [activeTab, setActiveTab] = useState<Tab>("home");
  // App-wide state
  const [isDark, setIsDark] = useState(false);
  const [language, setLanguage] = useState("English");
  const [user, setUser] = useState<AppUser | null>(null);

  const screen = stack[stack.length - 1];
  const goTo = (s: Screen) => setStack((p) => [...p, s]);
  const goBack = () => setStack((p) => (p.length > 1 ? p.slice(0, -1) : p));
  const navTo = (tab: Tab) => {
    setActiveTab(tab);
    setStack([tab as Screen]);
  };
  const goHome = () => { setActiveTab("home"); setStack(["home"]); };

  // Auth helpers
  const login = (u: AppUser) => { setUser(u); navTo("home"); };
  const logout = () => { setUser(null); };

  const ctxValue: AppCtxType = {
    isDark, toggleDark: () => setIsDark(p => !p),
    language, setLanguage,
    user, login, logout,
  };

  const mainScreens: Screen[] = ["home", "quran", "qibla", "saved", "more"];
  const showNav = mainScreens.includes(screen);

  const renderScreen = () => {
    switch (screen) {
      case "splash":       return <SplashScreen onDone={() => setStack(["onboard1"])} />;
      case "onboard1":     return <Onboard1 onNext={() => setStack(["onboard2"])} onSkip={() => setStack(["home"])} onLogin={() => setStack(["login"])} />;
      case "onboard2":     return <Onboard2 onDone={() => setStack(["signup"])} onLogin={() => setStack(["login"])} />;
      case "home":         return <HomeScreen onNav={navTo} goTo={goTo} />;
      case "donate":       return <DonateScreen goBack={goBack} goTo={goTo} />;
      case "donate-checkout": return <DonateCheckout goBack={goBack} goTo={goTo} />;
      case "donate-success":  return <DonateSuccess onHome={goHome} />;
      case "order":        return <OrderScreen goBack={goBack} goTo={goTo} />;
      case "order-detail": return <OrderDetail goBack={goBack} goTo={goTo} />;
      case "order-success": return <OrderSuccess onHome={goHome} />;
      case "quran":        return <QuranHome onReader={() => goTo("quran-reader")} />;
      case "quran-reader": return <QuranReader goBack={goBack} />;
      case "qibla":        return <QiblaScreen goTo={goTo} />;
      case "saved":        return <SavedScreen />;
      case "more":         return <MoreScreen goTo={goTo} />;
      case "ask-scholar":  return <AskScholar goBack={goBack} />;
      case "new-muslim":      return <NewMuslimScreen goBack={goBack} goTo={goTo} />;
      case "how-to-pray":     return <HowToPrayScreen goBack={goBack} goTo={goTo} />;
      case "what-is-islam":   return <WhatIsIslamScreen goBack={goBack} />;
      case "what-is-quran":   return <WhatIsQuranScreen goBack={goBack} goTo={goTo} />;
      case "who-is-prophet":  return <WhoIsProphetScreen goBack={goBack} />;
      case "learn":        return <LearnScreen goBack={goBack} />;
      case "profile":         return <ProfileScreen goBack={goBack} goTo={goTo} />;
      case "login":           return <LoginScreen goTo={goTo} goBack={goBack} />;
      case "signup":          return <SignupScreen goTo={goTo} goBack={goBack} />;
      case "language-select": return <LanguageSelectScreen goBack={goBack} />;
      case "wudu-guide":   return <WuduGuideScreen goBack={goBack} />;
      case "umrah-hajj":   return <UmrahHajjScreen goBack={goBack} goTo={goTo} />;
      case "logistics":    return <LogisticsScreen goBack={goBack} />;
      case "umrah-guide":  return <UmrahGuideScreen goBack={goBack} />;
      case "hajj-guide":   return <HajjGuideScreen goBack={goBack} />;
      case "spiritual-prep":    return <SpiritualPrepScreen goBack={goBack} />;
      case "donation-history":  return <DonationHistoryScreen goBack={goBack} />;
      case "order-history":     return <OrderHistoryScreen goBack={goBack} />;
      case "receipts":          return <ReceiptsScreen goBack={goBack} />;
      case "bookmarks":         return <BookmarksScreen goBack={goBack} />;
      case "reading-progress":  return <ReadingProgressScreen goBack={goBack} />;
      case "privacy-policy":    return <PrivacyPolicyScreen goBack={goBack} />;
      case "terms-conditions":  return <TermsConditionsScreen goBack={goBack} />;
      case "faq":          return <FAQScreen goBack={goBack} />;
      case "about-us":       return <AboutUsScreen goBack={goBack} />;
      case "books-articles": return <BooksArticlesScreen goBack={goBack} goTo={goTo} />;
      default:             return null;
    }
  };

  return (
    <AppCtx.Provider value={ctxValue}>
    <div
      className="min-h-screen flex items-center justify-center"
      style={{
        background: isDark
          ? "linear-gradient(135deg, #060c12 0%, #0a1520 100%)"
          : "linear-gradient(135deg, #0d1b2a 0%, #1a2a3a 50%, #0d1b2a 100%)",
        fontFamily: "'Inter', -apple-system, sans-serif",
      }}
    >
      {/* Subtle outer glow */}
      <div
        className="absolute rounded-full blur-3xl opacity-20 pointer-events-none"
        style={{ width: 600, height: 600, background: yellow, top: "50%", left: "50%", transform: "translate(-50%,-50%)" }}
      />

      {/* Phone shell */}
      <div
        className="relative overflow-hidden"
        style={{
          width: 390,
          height: 844,
          borderRadius: 52,
          background: "#000",
          boxShadow: "0 60px 140px rgba(0,0,0,0.7), 0 0 0 1px rgba(255,255,255,0.06), inset 0 0 0 1px rgba(255,255,255,0.04)",
        }}
      >
        {/* Dynamic island */}
        <div
          className="absolute top-3 left-1/2 -translate-x-1/2 z-50 rounded-full"
          style={{ width: 120, height: 34, background: "#000", boxShadow: "0 0 0 1px rgba(255,255,255,0.06)" }}
        />

        {/* Screen */}
        <div className="absolute inset-0" style={{ borderRadius: 52, overflow: "hidden" }}>
          {renderScreen()}

          {/* Bottom nav overlay */}
          {showNav && (
            <div className="absolute bottom-0 left-0 right-0 z-40">
              <BottomNav active={activeTab} onNav={navTo} />
            </div>
          )}
        </div>

        {/* Home indicator */}
        <div
          className="absolute bottom-2 left-1/2 -translate-x-1/2 z-50 rounded-full"
          style={{ width: 130, height: 4, background: "rgba(255,255,255,0.22)" }}
        />
      </div>

      {/* Screen label hint */}
      <div className="absolute bottom-6 text-xs font-medium" style={{ color: "rgba(255,255,255,0.25)" }}>
        Tap to navigate · Donate Quran App
      </div>
    </div>
    </AppCtx.Provider>
  );
}
