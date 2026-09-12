export const validar = (schema) => {
    return (req, res, next) => {
        const resultado = schema.safeParse(req.body);
        if (!resultado.success) {
            return res.status(400).json({
                erros: resultado.error.issues.map(
                    (issue) => ({
                        campo: issue.path.join("."),
                        mensagem: issue.message,
                    })
                )
            });
        }
        req.body = resultado.data;
        next();
    }
};