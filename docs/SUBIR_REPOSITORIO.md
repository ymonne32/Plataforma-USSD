# Subir el proyecto a GitHub o GitLab

El repositorio local ya está inicializado con commit en la rama `main`.

## GitHub (recomendado)

1. Entra en [https://github.com/new](https://github.com/new)
2. Nombre del repositorio, por ejemplo: `reto-qa-ussd-grpc`
3. **No** marques "Add a README" (ya existe en el proyecto)
4. Crea el repositorio vacío
5. En PowerShell, desde la carpeta del proyecto:

```powershell
cd c:\Trabajo\Hakom\RetoQA

git remote add origin https://github.com/TU_USUARIO/reto-qa-ussd-grpc.git
git push -u origin main
```

(Sustituye `TU_USUARIO` y el nombre del repo.)

## GitLab

1. [https://gitlab.com/projects/new](https://gitlab.com/projects/new) → Create blank project
2. Sin inicializar con README
3. Ejecuta:

```powershell
cd c:\Trabajo\Hakom\RetoQA

git remote add origin https://gitlab.com/TU_USUARIO/reto-qa-ussd-grpc.git
git push -u origin main
```

## SSH (si usas llaves)

```powershell
git remote add origin git@github.com:TU_USUARIO/reto-qa-ussd-grpc.git
git push -u origin main
```

## Verificar

```powershell
git remote -v
git status
```

## Enlace para la entrega Hakom

Repositorio publicado:

**https://github.com/ymonne32/Plataforma-USSD**

Inclúyelo en el correo de entrega junto con `docs/INDICE_ENTREGA.md`.
