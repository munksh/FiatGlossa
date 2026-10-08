Name:       harbour-fiatglossa
Summary:    Fiat Glossa, a small translator
Version:    1.1
Release:    1
License:    MIT
URL:        https://github.com/munksh/FiatGlossa
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  desktop-file-utils

%description
A small translator for Sailfish OS, in the Fiat family. Translates with DeepL
using your own API key, and settles British against American spelling on the
phone without asking anyone.

%if 0%{?_chum}
Title: Fiat Glossa
Type: desktop-application
DeveloperName: Munkstolen
Categories:
 - Office
 - Utility
AIRating: V
AINote: Claude is my typist - I cross review with Mistral, and add the code once it looks good. Architecture, design, on-device testing, releases and maintenance by me; issues and input welcome.
PackageIcon: https://munkstolen.se/SFOS/harbour-fiatglossa.png
Screenshots:
 - https://munkstolen.se/SFOS/fiatglossa1.png
 - https://munkstolen.se/SFOS/fiatglossa2.png
 - https://munkstolen.se/SFOS/fiatglossa3.png
Custom:
  Repo: https://github.com/munksh/FiatGlossa
Links:
  Homepage: https://github.com/munksh/FiatGlossa
  Bugtracker: https://github.com/munksh/FiatGlossa/issues
%endif

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5 APP_VERSION=%{version}
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
make install INSTALL_ROOT=%{buildroot}

desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
  %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
